#!/usr/bin/env python3

from typing import List

def max_num(nums: List[int]):
        ans = []
        size = len(nums)

        ans = nums
        for i in range(1,size):
                num_order = f"{ans[i-1]}{ans[i]}"
                num_revert = f"{ans[i]}{ans[i-1]}"
                print(f"num_order:{num_order},num_revert:{num_revert}")
                if num_order < num_revert:
                        switch = ans[i-1]
                        ans[i-1]=ans[i]
                        ans[i]=switch

                print(f" -> i ans:{ans}")
                for j in range(1, size-i+1):
                        num_order = f"{ans[j-1]}{ans[j]}"
                        num_revert = f"{ans[j]}{ans[j-1]}"
                        print(f"-> j:{j}: num_order:{num_order},num_revert:{num_revert}")
                        if num_order < num_revert:
                                switch = ans[j-1]
                                ans[j-1]=ans[j]
                                ans[j]=switch

        result = ''.join(map(str,ans))

        print(f"----> ans:{ans} result:{result}")

        return ans

nums = [1, 2, 40, 43, 5, 6, 7, 98, 97]
max_num(nums)