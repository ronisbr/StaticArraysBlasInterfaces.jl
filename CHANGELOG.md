StaticArraysBlasInterface.jl Changelog
======================================

Version 0.1.0
-------------

- Initial version.
  - This version implements the interface between `StaticMatrix` and the BLAS functions to
    compute the singular value decomposition (SVD). Hence, by loading this package, the
    functions `svd` and `pinv` does not allocate anymore if the input is a `StaticMatrix`
    (`Float32` or `Float64`).

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/Deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/Feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/Enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/Bugfix-purple.svg
[badge-info]: https://img.shields.io/badge/Info-gray.svg
