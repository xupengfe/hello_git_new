#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only

import re
import sys
import json
import subprocess as sp
from pathlib import Path

SC_BASE_URL = "https://github.com/koalaman/shellcheck/wiki/SC"

class DiffFile:
    def __init__(self, text: str):
        items = text.split("\t")
        self.Dtype = items[0]
        self.Dpath = items[1]

    def __repr__(self):
        return f"<DiffFile type={self.Dtype} path={self.Dpath}>"

class CheckResult:
    def __init__(self, diff_file: DiffFile):
        self._diff_file = diff_file
        self.errors = []
        self.fixes = []

    def __str__(self):
        s = f"\n>>>> Taints found in file: {self._diff_file.Dpath}"
        if self.errors:
            s += f"\n>>>> Hints:"
            for hint in self.errors:
                s += f"\n    {hint}"
        if self.fixes:
            s += f"\n>>>> Fixes:"
            for fix in self.fixes:
                s += f"\n    {fix}"
        return s


class BashChecker:
    EXCLUDE_CODES = [1090, 1091, 2010, 2011, 2012, 2013, 2086, 2126, 2206]

    def __init__(self, df: DiffFile):
        self._diff_file = df
        self._raw = []

    def do(self):
        code = ",".join([str(c) for c in self.EXCLUDE_CODES])
        # Debug: cmd = f"shellcheck -e {code} -s bash -f json ../../{self._diff_file.Dpath}"
        cmd = f"shellcheck -e {code} -s bash -f json {self._diff_file.Dpath}"
        print(f"cmd:{cmd}")
        errors = json.loads(sp.getoutput(cmd))

        result = CheckResult(self._diff_file)
        if not len(errors):
            return None

        for error in errors:
            file = error["file"]
            line = error["line"]
            msg = error["message"]
            code = error["code"]
            result.errors.append(f"{file}:{line} - {msg}, refer to {SC_BASE_URL}{code}")

        return result


class CChecker:
    def __init__(self, df: DiffFile):
        self._diff_file = df

    def do(self):
        pattern = r"total: (\d{1,}) errors, (\d{1,}) warnings, (\d{1,}) checks,.+"
        cmd = f"checkpatch.pl --no-tree --codespell --strict --fix --file {self._diff_file.Dpath}"
        errors = 0
        warnings = 0
        output = sp.getoutput(cmd)
        result = CheckResult(self._diff_file)

        for line in output.split("\n"):
            result.errors.append(line)

            match = re.search(pattern, line)
            if match:
                errors, warnings, _ = match.groups()
                break

        # We only care about errors and warnings
        if not int(errors) and not int(warnings):
            return None

        fix_file = Path(f"{self._diff_file.Dpath}.EXPERIMENTAL-checkpatch-fixes")
        if fix_file.exists():
            result.fixes.extend(fix_file.read_text().split("\n"))

        return result


def new_checker(df: DiffFile):
    # Debug:if df.Dtype == "D" or not Path(f"../../{df.Dpath}").exists():
    if df.Dtype == "D" or not Path(df.Dpath).exists():
        return

    if df.Dpath.endswith(".sh") and df.Dtype in ["A", "M"]:
        return BashChecker(df)
    elif df.Dtype in ["A", "M"] and (
        df.Dpath.endswith(".c") or df.Dpath.endswith(".h")
    ):
        return CChecker(df)


class DiffText:
    def __init__(self, dt: list):
        self._file_list = [DiffFile(i) for i in dt]

    @classmethod
    def load_diff(cls, diff_from, diff_to):
        cmd = f"git diff --name-status {diff_from}..{diff_to}"
        #cmd = "M       scan_bisect.sh\nM       make_bz.sh"
        code, output = sp.getstatusoutput(cmd)
        if code:
            raise Exception(f"fail to get diff - {output}")
        print(f"output:{output}")
        # Convert the \n strings as a list
        dt = [i for i in output.split("\n") if i]
        return cls(dt)

    def process(self):
        results = []

        for df in self._file_list:
            checker = new_checker(df)
            print(f"df:{df} | checker:{checker}")
            if checker is None:
                continue

            print(f"checking {df.Dpath} ...")

            result = checker.do()
            if result is None:
                continue

            results.append(result)

        for result in results:
            print(result)

        if len(results):
            sys.exit(1)


DiffText.load_diff(sys.argv[1], sys.argv[2]).process()
