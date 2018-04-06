using Base.Test
using Distributions
using Compat

# the -f option will cause fatal errors to error out runtests
fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"

# the -q option will quiet out error printing
quiet = length(ARGS) > 0 && ARGS[1] == "-q"

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
