# Lumping Metrics

optLump is able to lump based on a variety of metrics. Usually, mutual
information will be the correct choice, but this document also outlines
the alternatives.

## Mutual Information

The main goal of the package is to optimize for mutual information. This
is a very abridged outline of what the mutual information means and how
to interpret it. For a more thorough treatment of information theory,
see Cover and Thomas (1991), particularly chapter 2.

The *mutual information* between two random variables expresses how much
knowing the value of one of them reveals about the distribution of the
other. Mathematically, it is expressed as I(X; Y) = \sum\_{x \in
\mathcal{X}} \sum\_{y \in \mathcal{Y}} \mathbb{P}(X = x, Y = y) \log
\frac{\mathbb{P}(X = x, Y = y)}{\mathbb{P}(X = x) \mathbb{P}( Y = y)}
where, if the logarithm is taken to be natural, we have units of nats.
[^1]

Another useful quantity from information theory is the *entropy*, which
can intuitively be thought of as the information content of a random
variable, or how much ‘suprise’ the distribution contains. It has a
similar form to the mutual information, being H(X) = -\sum\_{x \in
\mathcal{X}} \mathbb{P}(X = x) \log \mathbb{P}(X = x).

It turns out that, for our application, the mutual information and
entropy are identical, since if we take X to be the distribution of the
variable before the lumping and Y to be the distribution after, we have
I(X;Y) = H(Y), so the actual quantity optimized for is H(Y). This means
we get two ways of interpreting optimizing for the mutual information:

- When we regard ourselves as optimizing for the mutual information, we
  try to find a lumping such that, upon knowing the value of the
  variable after lumping, we know as much as possible about the value
  before lumping. In other words, it should be possible to recover the
  original value with as much certainty as possible.
- When we look at the entropy, we are trying to find a lumping that is
  as disordered as possible. This is desirable, since the more
  disordered the variable is, the more information it contains. In
  practice, this means we try to find a lumping such that the
  distribution of the variable after lumping is as close to uniform as
  possible. [^2]

### Heuristics

Since computing the actual entropy is in general computationally
infeasible (see
[`lump_nominal_heuristic()`](https://daankoning.github.io/optLump/reference/lump_nominal_heuristic.md)),
there is a choice of multiple different heuristics to approximate the
optimal solution. The different heuristics all operate differently and
therefore also respond differently to an increase in the size of m, the
number of levels.

#### Smart

Usually the best choice, as it tends to approximate the optimal solution
more closely. Works by greedily lumping the smallest level with the
other level that results in the least information loss. On top of this
greedy approach, a simple look-ahead is also implemented, which usually
allows it to prevent getting stuck in unsolvable situations. Has
O\left(m^2\right) runtime.

#### Largest

Iteratively lumps the smallest level with the largest other level it can
be lumped with. In practice, the algorithm results in one large hard to
interpret group and probably ought be avoided. Has O\left(m^2\right)
runtime.

#### Other

Can be seen as a re-implementation of `forcats::fct_lump_min`, in that
it tries to lump the smallest levels together, with the added
flexibility provided by support for non-complete preference graphs. Has
O\left(m^2\right) runtime.

## Alternative Metrics

For the sake of a simpler interpretation, it is also possible to use
metrics other than the mutual information.

### Bin Count

One option is to aim for the lowest number of levels after lumping is
complete. This is equivalent to minimizing the number of ‘lumping
actions’, or amount of times multiple levels are combined together.

### Surplus

The other option is having the lowest surplus contents in each level.
The surplus is calculated as the amount of samples each level contains
in excess of the threshold. These surpluses are aggregated using a
simple sum, yielding the cost function being optimized for.

## References

Cover, Thomas M., and Joy A. Thomas. 1991. *Elements of Information
Theory*. 1st ed. Wiley Series in Telecommunications. John Wiley & Sons.

[^1]: It might be more intuitive to think in terms of bits, which we get
    when the logarithm is taken to be base 2. However, since the base of
    the logarithm only changes the mutual information by a constant
    factor, it does not affect the optimization process.

[^2]: This happens because the uniform distribution is the distribution
    with maximal entropy.
