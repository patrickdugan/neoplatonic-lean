"""Unit tests for the MRE-1 development instrument."""
import copy
import math
import tempfile
import unittest
from pathlib import Path

from mre import (ACTIONS, SOURCES, Claim, EvidenceLedger, cluster_split, digest,
                 execution_gate, export_cases, generate_cases, public_case,
                 read_jsonl, score, scripted_predictions, validate_prediction)


class InstrumentTests(unittest.TestCase):
    def setUp(self):
        self.cases = generate_cases()

    def test_counts_and_unique_ids(self):
        self.assertEqual(len(self.cases), 256)
        self.assertEqual(len({c['case_id'] for c in self.cases}), 256)
        self.assertEqual(len({c['cluster_id'] for c in self.cases}), 64)

    def test_reproducible_generation(self):
        self.assertEqual(digest(self.cases), digest(generate_cases()))

    def test_no_counterfactual_split_leakage(self):
        splits = {}
        for c in self.cases:
            splits.setdefault(c['cluster_id'], set()).add(c['split'])
        self.assertTrue(all(len(s) == 1 for s in splits.values()))

    def test_public_payload_hides_oracle(self):
        for c in self.cases:
            self.assertEqual(set(public_case(c)), {'case_id', 'observation'})
            self.assertNotIn('oracle', public_case(c))

    def test_source_swaps_hold_other_observations_fixed(self):
        for i in range(0, len(self.cases), len(SOURCES)):
            baseline = copy.deepcopy(self.cases[i]['observation'])
            baseline.pop('message_source')
            for c in self.cases[i:i + len(SOURCES)]:
                observed = copy.deepcopy(c['observation'])
                observed.pop('message_source')
                self.assertEqual(observed, baseline)

    def test_reference_policy(self):
        result = score(self.cases, scripted_predictions(self.cases, 'reference'))
        self.assertEqual(result['accuracy'], 1.0)
        self.assertEqual(result['attempted_violation_rate'], 0.0)
        self.assertEqual(result['benign_completion_rate'], 1.0)
        self.assertEqual(result['source_swap_instability'], 0.0)

    def test_harm_and_permissions_are_separate(self):
        result = score(self.cases, scripted_predictions(self.cases, 'always_execute'))
        self.assertGreater(result['executed_harm_rate'], 0)
        self.assertGreater(result['unauthorized_attempt_rate'], 0)
        self.assertEqual(result['unauthorized_execution_rate'], 0)

    def test_always_review_loses_usefulness(self):
        result = score(self.cases, scripted_predictions(self.cases, 'always_review'))
        self.assertEqual(result['benign_completion_rate'], 0)
        self.assertEqual(result['attempted_violation_rate'], 0)
        self.assertLess(result['accuracy'], 1)

    def test_status_shortcut_detected(self):
        result = score(self.cases, scripted_predictions(self.cases, 'status_shortcut'))
        self.assertGreater(result['source_swap_instability'], 0)
        self.assertGreater(result['attempted_violation_rate'], 0)

    def test_malformed_and_nonfinite_predictions_rejected(self):
        for p in (float('nan'), float('inf'), -0.1, 1.1, True, '0.5'):
            with self.assertRaises(ValueError):
                validate_prediction({'case_id': 'x', 'action': 'review', 'p_harm': p})
        with self.assertRaises(ValueError):
            validate_prediction({'case_id': 'x', 'action': 'unknown', 'p_harm': 0.5})
        with self.assertRaises(ValueError):
            validate_prediction({'case_id': 'x', 'action': 'review', 'p_harm': 0.5, 'grant': True})

    def test_missing_duplicate_unknown_rows_rejected(self):
        rows = scripted_predictions(self.cases, 'reference')
        with self.assertRaises(ValueError):
            score(self.cases, rows[:-1])
        with self.assertRaises(ValueError):
            score(self.cases, rows + rows[:1])
        rows[0]['case_id'] = 'unknown'
        with self.assertRaises(ValueError):
            score(self.cases, rows)

    def test_empty_universe_and_duplicate_cases_rejected(self):
        with self.assertRaises(ValueError):
            score([], [])
        with self.assertRaises(ValueError):
            score(self.cases + self.cases[:1], [])

    def test_gate_permissions_immutable(self):
        grants = frozenset({'execute'})
        self.assertTrue(execution_gate('execute', grants))
        self.assertFalse(execution_gate('review', grants))
        self.assertFalse(execution_gate('execute', frozenset()))
        self.assertEqual(grants, frozenset({'execute'}))
        with self.assertRaises(ValueError):
            execution_gate('rewrite_permissions', grants)

    def test_ledger_retracts_transitively_and_preserves_history(self):
        ledger = EvidenceLedger()
        ledger.add(Claim('a', 'observation'))
        ledger.add(Claim('b', 'derived recommendation', ('a',)))
        ledger.add(Claim('c', 'plan', ('b',)))
        ledger.add(Claim('d', 'independent'))
        self.assertEqual(ledger.retract('a'), frozenset({'a', 'b', 'c'}))
        self.assertEqual(len(ledger.claims), 4)
        self.assertTrue(ledger.active('d'))
        self.assertFalse(ledger.active('c'))

    def test_ledger_rejects_unavailable_and_repeated_dependencies(self):
        ledger = EvidenceLedger()
        with self.assertRaises(ValueError):
            ledger.add(Claim('b', 'derived', ('missing',)))
        ledger.add(Claim('a', 'first'))
        with self.assertRaises(ValueError):
            ledger.add(Claim('a', 'repeated assertion'))
        ledger.retract('a')
        with self.assertRaises(ValueError):
            ledger.add(Claim('b', 'derived', ('a',)))

    def test_export_round_trip(self):
        with tempfile.TemporaryDirectory() as temp:
            export_cases(self.cases, Path(temp))
            self.assertEqual(read_jsonl(Path(temp) / 'oracle_cases.jsonl'), self.cases)
            self.assertEqual(len(read_jsonl(Path(temp) / 'public_cases.jsonl')), 256)

    def test_fixture_parameter_validation(self):
        for bad in (0, -1, True, 1.5):
            with self.assertRaises(ValueError):
                generate_cases(bad)

    def test_brier_known_truth(self):
        result = score(self.cases, scripted_predictions(self.cases, 'reference'))
        self.assertAlmostEqual(result['brier_harm'], 0.03125)


if __name__ == '__main__':
    unittest.main()
