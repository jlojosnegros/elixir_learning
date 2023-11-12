#############################
# Initialize the population:
#############################

# use 100 bitstring of length 1000
n_bitstrings = 100
length_bitstring = 1000
max_result = length_bitstring

evaluate = fn population ->
  # This function takes a population
  # evaluates that population each of the element's (chromosomes) with a "fitness" function
  # and order the chromosomes based on each chromosome's fitness
  # fitness is just an heuristic that tells you how good or bad a solution is.

  # Sort population with those with greater sum of elements before.
  Enum.sort_by(population, &Enum.sum/1, &>=/2)
end

selection = fn population ->
  # This function will take the sorted population and return pairs of "parents"
  # so the "crossover" function could combine them to get a nice new generation

  # Return a list of tuples with two parents of the aprox same fitness to combine
  population
  |> Enum.chunk_every(2)
  |> Enum.map(&List.to_tuple(&1))
end

crossover = fn population ->
  # This is the "reproduction" function
  # We take two ( or more ) chromosomes as parents and produce two (or more) chromosomes as childs

  # for each pair of parents (selection creted the tuples)
  # select a random mid point to cut them (cx_point)
  # cut them into head and tail
  # combine crossing head an tail to get new chromosomes
  Enum.reduce(population, [], fn {p1, p2}, acc ->
    cx_point = :rand.uniform(length_bitstring)
    {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}

    [h1 ++ t2, h2 ++ t1 | acc]
  end)
end

algorithm = fn population, algorithm ->
  best = Enum.max_by(population, &Enum.sum/1)
  IO.write("\rCurrent best: " <> Integer.to_string(Enum.sum(best)))

  # This is the termination condition
  if Enum.sum(best) == max_result do
    best
  else
    # Algorithm is defined as a series of transformations over an initial population
    # Initial population for this iteration
    population
    # Evaluate all the population
    |> evaluate.()
    # Select the best parents for the new generation
    |> selection.()
    # Create childrens
    |> crossover.()
    # Repeat until get the result
    |> algorithm.(algorithm)
  end
end

population = for _ <- 1..n_bitstrings, do: for(_ <- 1..length_bitstring, do: Enum.random(0..1))
solution = algorithm.(population, algorithm)
IO.write("\n Answer is \n")
IO.inspect(solution)
