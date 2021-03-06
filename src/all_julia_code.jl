#################### beliefs 1
abstract type POMDP{S,A,O} end
####################

#################### beliefs 2
abstract type Updater end
####################

#################### beliefs 3
struct DiscreteBelief{P<:POMDP, S}
    pomdp::P
    states::Vector{S}
    b::Vector{Float64}
end
DiscreteBelief(pomdp, b::Vector{Float64}) =
	DiscreteBelief(pomdp, ordered_states(pomdp), b)
####################

#################### beliefs 4
pdf(b::DiscreteBelief, s) = b.b[state_index(b.pomdp, s)]
####################

#################### beliefs 5
mutable struct DiscreteUpdater{P<:POMDP} <: Updater
    pomdp::P
end
function update(bu::DiscreteUpdater, b::DiscreteBelief, a, o)
    b′ = zeros(length(b.states))
    for (si′, s′) in enumerate(b.states)
        po = pdf(observation(b.pomdp, a, s′), o)
        b′[si′] = po * sum(
        	pdf(transition(b.pomdp, s, a), s′) * b.b[si]
        	for (si, s) in enumerate(b.states))
    end
    normalize!(b′, 1)
    return DiscreteBelief(b.pomdp, b.states, b′)
end
####################

