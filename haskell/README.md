## Build this
1. Get & install stack: `wget -qO- https://get.haskellstack.org/ | s`
2. Run `../test.sh` and `.././benchmark.py` as usual.

This uses stack LTS 18.18 / GHC 8.10.4, but with text-2.0.1 so we can
use the clutter package.

## Compare the Haskell versions

Run `./run.sh` to time all the versions. If you have nix installed,
it'll use `hyperfine` to get more accurate timings.

| Command               | Mean [s]           | Min [s] | Max [s] |
| :---                  | ---:               | ---:    | ---:    |
| BufwiseClutter        | 0.725 s ±  0.017 s | 0.705 s | 0.753 s |
| LinewiseClutter       | 1.015 s ±  0.025 s | 0.982 s | 1.047 s |
| BufwiseVHBS           | 1.346 s ±  0.027 s | 1.302 s | 1.376 s |
| LazyVH                | 2.075 s ±  0.035 s | 2.035 s | 2.139 s |
| StreamlyVH            | 2.082 s ±  0.082 s | 2.018 s | 2.262 s |
| StreamlyHMRef         | 2.228 s ±  0.033 s | 2.184 s | 2.275 s |
| LinewiseVH            | 2.348 s ±  0.077 s | 2.251 s | 2.504 s |
| LazyHMRef             | 2.782 s ±  0.057 s | 2.699 s | 2.884 s |
| StreamlyThreadedHMRef | 2.912 s ±  0.094 s | 2.824 s | 3.129 s |
| LazyHMBS              | 5.700 s ±  0.430 s | 5.356 s | 6.797 s |
| LazyMap               | 5.721 s ±  0.105 s | 5.594 s | 5.942 s |
| StreamingHMBS         | 6.246 s ±  0.099 s | 6.160 s | 6.488 s |

For comparison with the other benchmarks, on the same machine:
| Command              | Mean [s]      | Min [s] | Max [s] |
| :---                 | ---:          | ---:    | ---:    |
| optimized-c          | 0.243 ± 0.016 | 0.228   | 0.272   |
| simple-c             | 0.997 ± 0.054 | 0.951   | 1.119   |
| python3 optimized.py | 1.466 ± 0.054 | 1.410   | 1.569   |
| python3 simple.py    | 2.055 ± 0.020 | 2.026   | 2.087   |
