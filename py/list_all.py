#!/usr/bin/env python3

import sys
import os
import typing
from typing import List

class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        n = len(nums)
        ans, path = [], []

        def sort_list(i):
            if (i == n):
                ans.append(path[:])
                return
            for j in range(0, n):
                if nums[j] not in path:
                    path.append(nums[j])
                    print(f" -> Will sort i:{i},i+1:{i+1},j:{j}, path:{path}, nums[{j}]:{nums[j]}, nums[{i+1}]:{nums[i+1] if i+1 < n else 'NA'}, ans:{ans}")
                    sort_list(i+1)
                    print(f" <- Before pop path:{path}")
                    path.pop()
                    print(f"    After pop path:{path} ->")
        sort_list(0)

        return ans

nums= [1,2,3]
solution = Solution()
print(f"Permute all nums:{nums}")
p = solution.permute(nums)

#print(f"p:{p}")



