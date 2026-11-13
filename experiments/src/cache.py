"""Model outputs kept on disk, one JSON line per call, so a run resumes after Ctrl+C and the
analysis can be redone without the GPU."""

import json
from pathlib import Path


class JsonlCache:
    def __init__(self, path):
        self.path, self._d = Path(path), None

    def get(self, key, compute):
        """Value stored under `key` (any JSON-serializable list), computed and appended on a miss."""
        key = json.dumps(key)
        if self._d is None:
            self._d = {}
            for line in self.path.read_text().splitlines() if self.path.exists() else []:
                try:
                    row = json.loads(line)
                except json.JSONDecodeError:  # line cut by Ctrl+C: that call is made again
                    continue
                self._d[row["key"]] = row["answer"]
        if key not in self._d:
            value = compute()
            self.path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.path, "a") as f:
                # leading newline: a record never glues onto a line cut by an earlier Ctrl+C
                f.write("\n" + json.dumps({"key": key, "answer": value}))
            # stored as read back from JSON (tuples become lists), so hits and misses look alike
            self._d[key] = json.loads(json.dumps(value))
        return self._d[key]
