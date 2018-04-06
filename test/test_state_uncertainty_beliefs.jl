mutable struct BabyPOMDP <: POMDP{Int, Bool, Bool}
    r_feed::Float64
    r_hungry::Float64
    p_become_hungry::Float64
    p_cry_when_hungry::Float64
    p_cry_when_not_hungry::Float64
    γ::Float64
end

CryingBaby = BabyPOMDP(-5.0, -10.0, 0.1, 0.8, 0.1, 0.9)

updater(problem::BabyPOMDP) = DiscreteUpdater(problem)

n_states(::BabyPOMDP) = 2
n_actions(::BabyPOMDP) = 2
n_observations(::BabyPOMDP) = 2
state_index(::BabyPOMDP, s::Int) = s
action_index(::BabyPOMDP, a::Bool) = a

ordered_states(BabyPOMDP) = [1,2]

function transition(pomdp::BabyPOMDP, s::Int, a::Bool)
    if !a && s == 1 # did not feed when hungry
        return Categorical([1.0,0.0])
    elseif a # feed
        return Categorical([0.0,1.0])
    else # did not feed when not hungry
        return Categorical([pomdp.p_become_hungry, 1-pomdp.p_become_hungry])
    end
end

function observation(pomdp::BabyPOMDP, a::Bool, s′::Int)
    if s′ == 1 # hungry
        return BoolDistribution(pomdp.p_cry_when_hungry)
    else
        return BoolDistribution(pomdp.p_cry_when_not_hungry)
    end
end
observation(pomdp::BabyPOMDP, s::Int, a::Bool, s′::Int) = observation(pomdp, a, s′)

function reward(pomdp::BabyPOMDP, s::Int, a::Bool)
    r = 0.0
    if s == 1 # hungry
        r += pomdp.r_hungry
    end
    if a # feed
        r += pomdp.r_feed
    end
    return r
end

discount(p::BabyPOMDP) = p.γ

let
	b = DiscreteBelief(CryingBaby, [0.5,0.5])
	bu = DiscreteUpdater(CryingBaby)

	# Do not feed the baby and the baby cries
	a = false
	o = true
	b = update(bu, b, a, o)
	@test abs(norm(b.b - [0.9072, 0.0928], Inf)) < 1e-4

	# Feed the baby and the crying stops.
	a = true
	o = false
	b = update(bu, b, a, o)
	@test abs(norm(b.b - [0.0, 1.0], Inf)) < 1e-4

	# We do not feed the baby and the baby does not cry.
	a = false
	o = false
	b = update(bu, b, a, o)
	@test abs(norm(b.b - [0.0241, 0.9759], Inf)) < 1e-4
end