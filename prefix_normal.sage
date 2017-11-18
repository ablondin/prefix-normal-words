from itertools import product, combinations

def num_occurrences(word, letter):
    r"""
    Returns the number of occurrences of ``letter`` in ``word``.

    EXAMPLE::

        sage: num_occurrences(Word('01001'), '0')
        3
    """
    return sum(1 for wi in word if wi == letter)

def letter_complexity(word, letter, n):
    r"""
    Returns the ``letter`` complexity of ``word`` for ``n``.

    Let `a` be a letter, `w` be a word and `n` be a natural number. Then the
    `a`-complexity of `w` for `n` is the maximum number of occurrences of the
    letter `a` in any factor of length `n` of `w`.

    NOTE:

        When `a = 1`, this corresponds to the `F_1` function in the paper of
        Burcsi and al.

    EXAMPLE::

        sage: letter_complexity(Word('01001'), '1', 3)
        1
    """
    return max(num_occurrences(u, letter) for u in word.factor_iterator(n))

def is_prefix_normal(word):
    r"""
    Returns True if and only if ``word`` is prefix-normal.

    A word `w` is called prefix-normal if for any length `n`, the number of 1's
    in `\\pref_n(w)` is the maximal in comparison with all factors of length
    `n`.

    EXAMPLE::

        sage: is_prefix_normal(Word('1101011011'))
        False
        sage: is_prefix_normal(Word('1101101011'))
        True
    """
    return all(num_occurrences(p, '1') == letter_complexity(word, '1', len(p))\
               for p in word.prefixes_iterator())

def are_f1_equivalent(u, v):
    r"""
    Returns True if and only if ``u`` and ``v`` are `F_1`-equivalent.

    Two words `u` and `v` of the same length are `F_1`-equivalent if their
    `1`-complexity coincides for all possible lengths.

    EXAMPLE::

        sage: are_f1_equivalent(Word('1101011011'), Word('1101101011'))
        True
        sage: are_f1_equivalent(Word('1110011011'), Word('1101101011'))
        False
    """
    assert len(u) == len(v)
    return all(letter_complexity(u, '1', n) == letter_complexity(v, '1', n)\
               for n in range(2, len(u)))

def alphabet(word):
    r"""
    Returns the set of all letters occurring in ``word``.

    EXAMPLE::

        sage: alphabet(Word('01001')) == set('01')
        True
        sage: alphabet(Word('ababc')) == set('abc')
        True
    """
    return set(letter for letter in word)

def all_binary_words_with_k_ones(n, k):
    r"""
    Generates all words on `\{0,1\}` of length ``n`` with exactly ``k``
    occurrences of `1`.

    EXAMPLE::

        sage: list(all_binary_words_with_k_ones(4, 2))
        ['1100', '1010', '1001', '0110', '0101', '0011']
    """
    for combination in combinations(range(n), k):
        yield ''.join([str(int(l in combination)) for l in range(n)])

def f1_orbit_generator(word):
    r"""
    Generates all words in the same `F_1`-orbit as ``word``.

    EXAMPLE::

        sage: list(f1_orbit_generator(Word('01001')))
        [word: 10010, word: 01001]
        sage: list(f1_orbit_generator(Word('1101101011')))
        [word: 1101101011, word: 1101011011]
    """
    n = len(word)
    k = num_occurrences(word, '1')
    for u in all_binary_words_with_k_ones(n, k):
        u = Word(u)
        if are_f1_equivalent(word, u):
            yield u

def orbits_sizes_generator(length):
    r"""
    Generates the sizes of the `F_1`-orbits for all words of given ``length``.

    EXAMPLE::

        sage: list(orbits_sizes(4))
        [1, 4, 1, 2, 3, 2, 2, 1]
    """
    for word in product('01', repeat=length):
        word = Word(word)
        if is_prefix_normal(word):
            yield sum(1 for _ in f1_orbit_generator(word))

def orbit_graph(word, max_dist=6):
    r"""
    Returns the orbit's graph of the given word.

    The adjacency relation is given by the maximum allowed distance. In other
    words, there is an edge between `u` and `v` if and only if the letters of
    `u` and `v` differ in at most ``max_dist`` positions.

    EXAMPLES::

        sage: orbit_graph(Word('01001'))
        Graph on 2 vertices
        sage: orbit_graph(Word('01101'))
        Graph on 4 vertices
    """
    words = list(f1_orbit_generator(word))
    g = Graph()
    g.add_vertices(words)
    for u in words:
        for v in words:
            diff = [i for i in range(len(u)) if u[i] != v[i]]
            if len(diff) <= max_dist:
                g.add_edge(u, v, label=len(diff))
    return g
