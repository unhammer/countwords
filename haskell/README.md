## Build this
1. Get & install stack: `wget -qO- https://get.haskellstack.org/ | s`
2. Run `../test.sh` and `.././benchmark.py` as usual.

This uses stack LTS 18.18 / GHC 8.10.4, but with text-2.0.1 so we can
use the clutter package.

## Compare the Haskell versions

Run `./run.sh` to time all the versions. If you have nix installed,
it'll use `hyperfine` to get more accurate timings.

| Command               | Mean [s]      | Min [s] | Max [s] | dictionary lib       | streaming lib/method     |
| :---                  | ---:          | ---:    | ---:    | ---:                 | ---:                     |
| BufwiseFiniteBS       | 0.870 ± 0.008 | 0.860   | 0.882   | finite               | manual buffer management |
| BufwiseClutter        | 0.961 ± 0.010 | 0.949   | 0.975   | clutter              | manual buffer management |
| LinewiseClutter       | 1.240 ± 0.010 | 1.219   | 1.255   | clutter              | forEach line             |
| BufwiseVHBS           | 1.278 ± 0.007 | 1.268   | 1.291   | vector-hashtables    | manual buffer management |
| LazyVH                | 2.075 ± 0.035 | 2.035   | 2.139   | vector-hashtables    | lazy I/O                 |
| StreamlyVH            | 2.082 ± 0.082 | 2.018   | 2.262   | vector-hashtables    | streamly                 |
| StreamlyHMRef         | 2.228 ± 0.033 | 2.184   | 2.275   | unordered-containers | streamly                 |
| LinewiseVH            | 2.348 ± 0.077 | 2.251   | 2.504   | vector-hashtables    | forEach line             |
| LazyHMRef             | 2.782 ± 0.057 | 2.699   | 2.884   | unordered-containers | lazy I/O                 |
| StreamlyThreadedHMRef | 2.912 ± 0.094 | 2.824   | 3.129   | unordered-containers | streamly                 |
| LazyHMBS              | 5.700 ± 0.430 | 5.356   | 6.797   | unordered-containers | lazy I/O                 |
| LazyMap               | 5.721 ± 0.105 | 5.594   | 5.942   | containers           | lazy I/O                 |
| StreamingHMBS         | 6.246 ± 0.099 | 6.160   | 6.488   | unordered-containers | streaming                |

For comparison with the other benchmarks, on the same machine:
| Command              | Mean [s]      | Min [s] | Max [s] |
| :---                 | ---:          | ---:    | ---:    |
| optimized-c          | 0.243 ± 0.016 | 0.228   | 0.272   |
| simple-c             | 0.997 ± 0.054 | 0.951   | 1.119   |
| python3 optimized.py | 1.466 ± 0.054 | 1.410   | 1.569   |
| python3 simple.py    | 2.055 ± 0.020 | 2.026   | 2.087   |
