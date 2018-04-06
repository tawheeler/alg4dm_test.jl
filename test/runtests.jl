using Base.Test
using Distributions
using Compat

import Distributions: pdf
import Base: rand

# the -f option will cause fatal errors to error out runtests
fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"

# the -q option will quiet out error printing
quiet = length(ARGS) > 0 && ARGS[1] == "-q"

################

abstract type POMDP{S,A,O} end

abstract type Updater end

struct BoolDistribution
    p::Float64 # probability of true
end

pdf(d::BoolDistribution, s::Bool) = s ? d.p : 1.0-d.p
rand(rng::AbstractRNG, d::BoolDistribution) = rand(rng) <= d.p
iterator(d::BoolDistribution) = [true, false]
Base.:(==)(d1::BoolDistribution, d2::BoolDistribution) = d1.p == d2.p
Base.hash(d::BoolDistribution) = hash(d.p)
Base.length(d::BoolDistribution) = 2

################

include(Pkg.dir("alg4dm_test", "src", "all_julia_code.jl"))

my_tests = [
    "test_state_uncertainty_beliefs.jl",
    ]

println("Running tests:")

anyerrors = false
for my_test in my_tests
    try
        include(my_test)
        println("\t\033[1m\033[32mPASSED\033[0m: $(my_test)")
    catch e
        anyerrors = true
        println("\t\033[1m\033[31mFAILED\033[0m: $(my_test)")
        if fatalerrors
            rethrow(e)
        elseif !quiet
            showerror(STDOUT, e, backtrace())
            println()
        end
    end
end

if anyerrors
    throw("Tests failed")
end

println("DONE")
