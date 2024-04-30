## Build this
1. Get & install stack: `wget -qO- https://get.haskellstack.org/ | s`
2. Run `../test.sh` and `.././benchmark.py` as usual.

This uses stack LTS 18.18 / GHC 8.10.4, but with text-2.0.1 so we can
use the clutter package.

## Compare the Haskell versions

Run `./run.sh` to time all the versions. If you have nix installed,
it'll use `hyperfine` to get more accurate timings.

| Command               | Mean [s]      | Min [s] | Max [s] | dictionary lib       | streaming lib/method     |
| :---                  | ---:          |    ---: |    ---: | ---:                 | ---:                     |
| BufwiseFiniteBS       | 0.932 ± 0.018 |   0.901 |   0.956 | finite               | manual buffer management |
| BufwiseClutter        | 1.026 ± 0.012 |   1.003 |   1.044 | clutter              | manual buffer management |
| BufwiseVHBS           | 1.367 ± 0.070 |   1.306 |   1.557 | vector-hashtables    | manual buffer management |
| LinewiseClutter       | 1.380 ± 0.077 |   1.317 |   1.541 | clutter              | forEach line             |
| LazyVH                | 2.017 ± 0.024 |   1.985 |   2.050 | vector-hashtables    | lazy I/O                 |
| LinewiseVH            | 2.048 ± 0.017 |   2.026 |   2.072 | vector-hashtables    | forEach line             |
| StreamlyVH            | 2.673 ± 0.089 |   2.605 |   2.850 | vector-hashtables    | streamly                 |
| LazyHMRef             | 2.687 ± 0.027 |   2.656 |   2.725 | unordered-containers | lazy I/O                 |
| StreamlyHMRef         | 3.246 ± 0.156 |   3.117 |   3.567 | unordered-containers | streamly                 |
| StreamlyThreadedHMRef | 4.020 ± 0.040 |   3.974 |   4.094 | unordered-containers | streamly                 |
| LazyMap               | 5.946 ± 0.098 |   5.877 |   6.136 | containers           | lazy I/O                 |
| LazyHMBS              | 5.996 ± 0.098 |   5.938 |   6.272 | unordered-containers | lazy I/O                 |
| StreamingHMBS         | 6.367 ± 0.097 |   6.284 |   6.630 | unordered-containers | streaming                |

For comparison with the other benchmarks, on the same machine:
| Command              | Mean [s]      | Min [s] | Max [s] |
| :---                 | ---:          |    ---: |    ---: |
| optimized-c          | 0.252 ± 0.009 |   0.239 |   0.274 |
| simple-c             | 1.048 ± 0.055 |   0.970 |   1.129 |
| python3 optimized.py | 1.454 ± 0.088 |   1.351 |   1.622 |
| python3 simple.py    | 2.158 ± 0.036 |   2.114 |   2.230 |
