# Navigate to the root of the current Git repository.
function ..g
    cd (git rev-parse --show-toplevel)
end
