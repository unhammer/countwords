## Build this
1. Get & install stack: `wget -qO- https://get.haskellstack.org/ | s`
2. Run `../test.sh` and `.././benchmark.py` as usual.

This uses stack LTS 18.18 / GHC 8.10.4, but with text-2.0.1 so we can
use the clutter package.

## Compare the Haskell versions

Run `./run.sh` to time all the versions. If you have nix installed,
it'll use `hyperfine` to get more accurate timings.

| Command               | Mean [s]      | Min [s] | Max [s] |
| :---                  | ---:          | ---:    | ---:    |
| BufwiseClutter        | 0.931 ± 0.037 | 0.890   | 0.999   |
| LinewiseClutter       | 1.235 ± 0.049 | 1.155   | 1.301   |
| BufwiseVHBS           | 1.346 ± 0.027 | 1.302   | 1.376   |
| LazyVH                | 2.075 ± 0.035 | 2.035   | 2.139   |
| StreamlyVH            | 2.082 ± 0.082 | 2.018   | 2.262   |
| StreamlyHMRef         | 2.228 ± 0.033 | 2.184   | 2.275   |
| LinewiseVH            | 2.348 ± 0.077 | 2.251   | 2.504   |
| LazyHMRef             | 2.782 ± 0.057 | 2.699   | 2.884   |
| StreamlyThreadedHMRef | 2.912 ± 0.094 | 2.824   | 3.129   |
| LazyHMBS              | 5.700 ± 0.430 | 5.356   | 6.797   |
| LazyMap               | 5.721 ± 0.105 | 5.594   | 5.942   |
| StreamingHMBS         | 6.246 ± 0.099 | 6.160   | 6.488   |

For comparison with the other benchmarks, on the same machine:
| Command              | Mean [s]      | Min [s] | Max [s] |
| :---                 | ---:          | ---:    | ---:    |
| optimized-c          | 0.243 ± 0.016 | 0.228   | 0.272   |
| simple-c             | 0.997 ± 0.054 | 0.951   | 1.119   |
| python3 optimized.py | 1.466 ± 0.054 | 1.410   | 1.569   |
| python3 simple.py    | 2.055 ± 0.020 | 2.026   | 2.087   |
