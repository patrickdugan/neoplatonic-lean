"""JSON subprocess protocol example. This is a deterministic scripted agent."""
import json
import sys
from revision import scripted

request = json.load(sys.stdin)
print(json.dumps(scripted(request["observation"], sys.argv[1] if len(sys.argv) > 1 else "reference")))
