using CSV, DataFrames, GLM, Distributions, Random, MPI, ArgParse, RData, Dates

function parse_commandline()
  s = ArgParseSettings()

  @add_arg_table! s begin
  "--input", "-d"
    help = "data directory"
    required = true
  "--output", "-o"
    help = "output file prefix"
    default = "result"
  "--permutation", "-p"
    help = "number of permutations"
    arg_type = Int
    default = 1000000
  "--jobs", "-n"
    help = "number of jobs that will run in parallel"
    arg_type = Int
    default = 1
  end

  return parse_args(s)
end

function quit(msg)
  println(msg)
  MPI.Barrier(comm)
  MPI.Finalize()
  exit(1)
end


function fisher_psum(data)
  plist = []

  for i = 1:length(data)
    d = glm(@formula(y ~ a+x1+x2+g), data[i], Binomial())
    pvalue = coeftable(d).cols[4][5]
    append!(plist, pvalue)
  end

  return ccdf(Chisq(2*length(plist)), -2*sum(log.(plist)))
end

function perm_fisher_psum(data, npermute, orig)
  ret = 0

  rank = MPI.Comm_rank(subComm)
  if rank > 0
    nslave = MPI.Comm_size(subComm) - 1
    binsize = div(npermute, nslave)
    if rank == 1
      binsize += mod(npermute, nslave)
    end
    if npermute < nslave
      binsize = npermute
    end
    for loop = 1:binsize
      plist = []
      for i = 1:length(data)
        shuffle!(data[i][1])
        d = glm(@formula(y ~ a+x1+x2+g), data[i], Binomial())
        pvalue = coeftable(d).cols[4][5]
        append!(plist, pvalue)
      end
      ret += ifelse(ccdf(Chisq(2*length(plist)), -2*sum(log.(plist))) < orig, 1, 0)
    end
  end

  return ret
end


function master()
  if ! isdir(dir)
    quit("No such directory: ", dir)
  end

  exms = filter(x -> endswith(x, r"\.RData|.rdata|.rda"), readdir(dir, join=true))
  if length(exms) == 0
    quit("No data files in the directory")
  end
  njobs = length(exms)
  function producer(c::Channel)
    for i = 1:njobs
      put!(c, exms[i])
    end
  end
  jobs = Channel(producer)

  startsAt = Dict()
  results = DataFrame(snpid = String[], pvalue = Float64[], origpvalue = Float64[], nperm = Int[], runtime = Float64[])
  ncase = -1
  done = 0;
  while done < njobs
    status = MPI.Probe(MPI.MPI_ANY_SOURCE, MPI.MPI_ANY_TAG, MPI.COMM_WORLD)
    src = status.source
    tag = status.tag
    sleep(0.)
    job, status = MPI.recv(src, tag, MPI.COMM_WORLD)
    if tag == MPI_DONE
      done += 1
      sleep(0.)
      ncase, status = MPI.recv(src, MPI_DATA, MPI.COMM_WORLD)
      sleep(0.)
      orig, status = MPI.recv(src, MPI_DATA, MPI.COMM_WORLD)
      sleep(0.)
      elapsed_reduce, status = MPI.recv(src, MPI_DATA, MPI.COMM_WORLD)
      elapsed = time() - startsAt["$job"]
      pvalue = ncase / npermute
      println("job done: src $src, tag $tag, p-value $pvalue, orig $orig, elapsed $elapsed, elapsed(reduce) $elapsed_reduce")
      push!(results, (splitext(basename(job))[1], pvalue, orig, npermute, elapsed))
      CSV.write(resultFile, results, header=["SNP ID", "p-value", "orig. p-value", "num. permutation", "runtime"])
    end
    if isready(jobs)
      job = take!(jobs)
      println("send $job to $src")
      startsAt["$job"] = time()
      req = MPI.send(job, src, MPI_NEWJOB, MPI.COMM_WORLD)
    else
      req = MPI.send(0, src, MPI_DONE, MPI.COMM_WORLD)
    end
  end
  CSV.write(resultFile, results, header=["SNP ID", "p-value", "orig. p-value", "num. permutation", "runtime"])
end


function slave(job = "")
  alldone = false
  ncase = -1
  orig = -1
  while ! alldone
    if subRank == 0
      if job == ""
        req = MPI.send(ncase, 0, MPI_NEWJOB, MPI.COMM_WORLD)
      end
      status = MPI.Probe(0, MPI.MPI_ANY_TAG, MPI.COMM_WORLD)
      if status.tag == MPI_NEWJOB
        job, status = MPI.recv(status.source, MPI_NEWJOB, MPI.COMM_WORLD)
        data = load("$job", convert=true)["re.data"]
        orig = fisher_psum(data)
        for i = 1:subSize-1
          req = MPI.send(0, i, MPI_NEWJOB, subComm)
          req = MPI.send(data, i, MPI_DATA, subComm)
          req = MPI.send(orig, i, MPI_DATA, subComm)
        end
        elapsed = @elapsed ncase = MPI.Reduce(perm_fisher_psum(data, npermute, orig), +, 0, subComm)
        req = MPI.send(job, 0, MPI_DONE, MPI.COMM_WORLD)
        req = MPI.send(ncase, 0, MPI_DATA, MPI.COMM_WORLD)
        req = MPI.send(orig, 0, MPI_DATA, MPI.COMM_WORLD)
        req = MPI.send(elapsed, 0, MPI_DATA, MPI.COMM_WORLD)
      elseif status.tag == MPI_DONE
        for i = 1:subSize-1
          req = MPI.isend(0, i, MPI_DONE, subComm)
        end
        alldone = true
      else
        println("unknown tag $tag")
      end
    else
      status = MPI.Probe(0, MPI.MPI_ANY_TAG, subComm)
      junk, status = MPI.recv(0, MPI.MPI_ANY_TAG, subComm)
      if status.tag == MPI_NEWJOB
        sleep(0.)
        data, status = MPI.recv(0, MPI_DATA, subComm)
        sleep(0.)
        orig, status = MPI.recv(0, MPI_DATA, subComm)
        ncase = MPI.Reduce(perm_fisher_psum(data, npermute, orig), +, 0, subComm)
      else
        alldone = true
      end
    end
  end
end


const MPI_NEWJOB = 1
const MPI_DATA = 2
const MPI_DONE = 3
const ncores = 68
const opt_nnodes = 40
const node_unit = ncores * opt_nnodes

args = parse_commandline()
dir = args["input"]
output = args["output"]
npermute = args["permutation"]
npjobs = args["jobs"]

MPI.Init()
world_rank = MPI.Comm_rank(MPI.COMM_WORLD)
world_size = MPI.Comm_size(MPI.COMM_WORLD)
color = 0
if world_rank != 0
  color = div(world_rank, node_unit) + 1
end
subComm = MPI.Comm_split(MPI.COMM_WORLD, color, world_rank - 1)
subRank = MPI.Comm_rank(subComm)
subSize = MPI.Comm_size(subComm)

if world_rank == 0
  resultFile = joinpath(pwd(), output * "_" * Dates.format(Dates.now(), "YYYYmmddHHMM") * ".csv")
  master()
else
  slave()
end

MPI.Barrier(MPI.COMM_WORLD)
MPI.Finalize()

