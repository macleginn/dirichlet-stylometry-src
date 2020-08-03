using StatsBase
using SpecialFunctions
using CSV
using Random
using JSON

# Replicability

Random.seed!(42)

# Helper functions

function tabulate(v)
    d = Dict{String,Int64}()
    for el in v
        if haskey(d, el)
            d[el] += 1
        else
            d[el] = 1
        end
    end
    return d
end

function get_author(s)
    return split(s, "_")[1]
end

function log_ddirichlet(x, alphas)
    log_numer = 0
    for i = 1:length(x)
        log_numer += (alphas[i]-1) * log(x[i]+10^(-8))
    end
    log_denom = sum(loggamma.(alphas)) - loggamma(sum(alphas))
    return log_numer - log_denom
end

function get_dirichlet_pdf(alphas)
    return v -> (log_ddirichlet(v, alphas))
end

# The main ML estimator function

function fit_dirichlet(x)
    nrow, ncol = size(x)
    alphas = fill(1/ncol, ncol)
    log_p_bar = fill(0.0, ncol)
    eps = 10^(-5)
    for j = 1:ncol
        col = x[1:end,j]
        log_p_bar[j] = sum(log.(col.+0.0000001))/nrow
    end
    while true
        alphas_tmp = fill(0.0, ncol)
        for k = 1:ncol
            rhs = digamma(sum(alphas)) + log_p_bar[k]
            alphas_tmp[k] = invdigamma(rhs)
        end
        change = sum(abs.(alphas_tmp-alphas))
        if change < eps
            break
        end
        alphas = alphas_tmp
    end
    return alphas
end

println("Preparing data...")

# Read the data prepared by the R script.
d = CSV.read("relative_freqs.csv")

# We strip of the sample names and
# transpose the data (for historical reasons).
d_mat = transpose(convert(Matrix, d[1:end,2:end]))
sample_names = d[1:end,1]
author_names = [
    get_author(sample_name)
    for sample_name in sample_names
]

min_samples = 21 # 20 for fitting, 1 for testing

# major_authors are keys from the filtered dictionary
# containing sample sample counts per author.
major_authors = [
    el for el in keys(
    filter(p -> (last(p) >= min_samples),
           tabulate(author_names)))
]

author_indices = Dict()
for author in major_authors
    author_idx = [
        i for i in 1:length(author_names)
        if author_names[i] == author
    ]
    author_indices[author] = author_idx
end

# Ensure that each test sample gets used
# once by sampling them without replacement
test_indices = Dict()
for author in major_authors
    author_idx = author_indices[author]
    test_indices[author] = StatsBase.sample(author_idx,
                                            min_samples,
                                            replace = false)
end

# Dump test_indices to test other algos on them.
json_io = open("testing_indices.json", "w")
JSON.print(json_io, test_indices)

# # The main loop
# author_pairs = Tuple{String,String}[]
# # For stress testing
# num_training_samples = 5
# for iter in 1:min_samples
#     println("Iteration $(iter)")
#     fitted_log_pdf = Dict()
#     # Fit distributions
#     for author in major_authors
#         test_idx = test_indices[author][iter]
#         author_idx = author_indices[author]
#         train_idx = filter(x -> (x != test_idx),
#                            author_idx)
#         # Restrict the number of training samples
#         train_idx = StatsBase.sample(train_idx,
#                                      num_training_samples,
#                                      replace = false)
#         fitted_log_pdf[author] = get_dirichlet_pdf(
#             fit_dirichlet(transpose(d_mat[1:end,train_idx])))
#     end
#     # Select the best candidate for each test sample
#     for real_author in major_authors
#         max_likelihood = 0
#         best_candidate = ""
#         test_idx = test_indices[real_author][iter]
#         for candidate_author in major_authors
#             author_log_pdf = fitted_log_pdf[candidate_author]
#             likelihood = author_log_pdf(d_mat[1:end,test_idx])
#             if likelihood > max_likelihood
#                 max_likelihood = likelihood
#                 best_candidate = candidate_author
#             end
#         end
#         push!(author_pairs, (real_author, best_candidate))
#     end
# end

# # Dump the results
# textio = open("author_pairs_$(num_training_samples)_samples.csv", "w")
# write(textio, "RealAuthor,GuessedAuthor\n")
# for pair in author_pairs
#     real, candidate = pair
#     write(textio, "$(real),$(candidate)\n")
# end
# close(textio)

# Now fit the data using all available samples for author
# to estimate the mean and precision

# textio_alphas = open("author_alphas.csv", "w")
# for author in major_authors
#     author_idx = author_indices[author]
#     alphas = fit_dirichlet(transpose(d_mat[1:end,author_idx]))
#     alphas_str = join(alphas, ",")
#     println("$(author): $(alphas_str)")
#     write(textio_alphas, "$(author),$(alphas_str)\n")
# end
# close(textio_alphas)
