require 'nn'
require 'torch'

local NNLearner = {}
NNLearner.__index = NNLearner

function NNLearner.create(availableActions, args)
  local learner = {}
  setmetatable(learner, NNLearner)
  learner.availableActions = availableActions
  learner.learningRate = args.learningRate or 0.05
  learner.discountFactor = args.discountFactor or 0.9
  explorationRate = args.explorationRate or 0.1

  -- state, action, reward, new state
  memory = {}
  learner.mem_cap = 1000000

  learner.screen = torch.zeros(100)
  learner.criterion = nn.MSECriterion()
  learner.target = torch.zeros(5)

  learner.mlp = nn.Sequential();  -- make a multi-layer perceptron
  local inputs = 100
  local outputs = #availableActions
  local HUs = args.HUs or 400

  learner.start_time = os.clock()

  -- learner.mlp:add(nn.SpatialConvolution(1, 1, 3, 3))
  -- learner.mlp:add(nn.ReLU())
  --
  -- learner.mlp:add(nn.View(1*10*10))
  --
  -- learner.mlp:add(nn.Linear(1*10*10, outputs))

  learner.mlp:add(nn.Linear(inputs, HUs))
  learner.mlp:add(args.transfer or nn.ReLU())
  for i = 1, args.hiddenLayers do
    learner.mlp:add(nn.Linear(HUs, HUs))
    learner.mlp:add(args.transfer or nn.ReLU())
  end
  learner.mlp:add(nn.Linear(HUs, outputs))
  return learner
end

function NNLearner:q(observation)
  return self.mlp:forward(observation)
end

local function maxAction(q, availableActions)
  local max_q = - math.huge
  local action_index = -1
  for i, a in pairs(availableActions) do
    if q[i] > max_q then
      max_q = q[i]
      action_index = i
    end
    print(q[i])
  end
  return max_q, action_index
end

function NNLearner:act(observation)
  print(explorationRate)
  local r = math.random()
  print(r)
  if r < explorationRate then
    print("Chose random action: ")
    return self.availableActions[math.floor(
      math.random(#self.availableActions))]
  end
  local q_value, action_index = maxAction(self:q(observation), self.availableActions)
  print("Chose action: "..action_index.." with q value: "..q_value)
  return self.availableActions[action_index]
end

function NNLearner:store(observation, action, newObservation, reward, terminal)
  new_mem = {}
  new_mem.observation = observation
  new_mem.action = action
  new_mem.newObservation = newObservation
  new_mem.reward = reward
  new_mem.terminal = terminal

  if(#memory > self.mem_cap) then
    table.remove(memory, 1)
  end
  table.insert(memory, new_mem)
end

function NNLearner:retrieve()
  rand_mem = memory[math.random(#memory)]
  return rand_mem.observation, rand_mem.action, rand_mem.newObservation, rand_mem.reward, rand_mem.terminal
end

function NNLearner:learn()
  observation, action, newObservation, reward, terminal = self:retrieve()

  local q = self:q(newObservation)
  local max_q, _ = maxAction(q, self.availableActions)
  local action_index = -1
  for i, a in pairs(self.availableActions) do
    if a == action then
      action_index = i
    end
  end

  local pred = self:q(observation)
  for i = 1, pred:size(1) do
    self.target[i] = q[i] - pred[i]
  end
  if terminal then
    self.target[action_index] = reward
    print("Terminal")
  else
    self.target[action_index] = reward + self.discountFactor * max_q
  end

  local err = self.criterion:forward(pred, self.target)
  print("Error: "..err)
  local gradCriterion = self.criterion:backward(pred, self.target)

  -- accumulate gradients
  self.mlp:backward(observation, gradCriterion)
end

return NNLearner
