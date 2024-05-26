import gym
from gym import spaces
import numpy as np
import pandas as pd
import random
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Flatten
from tensorflow.keras.optimizers.legacy import Adam
from collections import deque
from rl.agents import DQNAgent  # pip install keras-rl2
from rl.policy import BoltzmannQPolicy  # important to have gym==0.25.2
from rl.memory import SequentialMemory

df = pd.read_csv('yf-ai-ready.csv')
data = {
    'tradehis': [],
    'actionhis': [],
    'budget': []
}
his = pd.DataFrame(data)
class CustomEnv(gym.Env):
    def __init__(self):
        super(CustomEnv, self).__init__()

        # We define the space of observation and action
        self.observation_space = spaces.Box(low=-np.inf, high=np.inf, shape=(11,), dtype=np.float32)
        self.action_space = spaces.Discrete(3)  # Two available actions: buy sell

        # Environmental parameters
        self.budget = 1000
        self.lastprice = None
        self.lastsell = False
        self.lastbuy = False
        self.result = 0
        self.dt = 1  # Krok czasowy
        self.countstep = 0
        self.storagetime = 0
        self.df = pd.read_csv('yf-ai-ready.csv')
        self.allresults = []
        self.allbudget = []
        self.tradehis = []
        self.actionhis = []
        self.his = his
        # Start state
        self.state = self.df.iloc[0].to_numpy()

    def reset(self):
        # Init stat state
        self.state = self.df.iloc[0].to_numpy()
        self.budget = 1000
        self.lastprice = None
        self.lastsell = False
        self.lastbuy = False
        self.result = 0
        self.dt = 1  # Time step
        self.countstep = 0
        self.storagetime = 0
        self.df = pd.read_csv('yf-ai-ready.csv')
        self.allresults = []
        self.allbudget = []
        self.tradehis = []
        self.actionhis = []
        return self.state

    def step(self, action):
        # Unpack state

        Index, Hour, Avr, MovingAverage5, MovingAverage20, MovingAverage50, H1percent, H7percent, H35percent, H140percent, _ = self.state

        # Math

        if self.lastbuy is False and action > 1:
            if self.lastsell is True:
                self.result = self.lastprice * 0.25 + (self.lastprice - (Avr + 3*Avr/10000)) * 0.25
                self.budget = self.budget + self.result
            else:
                self.lastprice = Avr + 3*Avr/10000
                self.lastbuy = True

        elif self.lastsell is False and action < 1:
            if self.lastbuy is True:
                self.result = (self.lastprice) + (Avr - self.lastprice)
                self.budget = self.budget + self.result
            else:
                self.lastprice = Avr
                self.lastsell = True
        else:
            pass

        self.storagetime = self.storagetime + 1

        if self.lastbuy and self.lastsell is True:
            self.lastbuy = False
            self.lastsell = False
            self.storagetime = 0

        self.his.loc[self.countstep, 'actionhis'] = action
        self.his.loc[self.countstep, 'budget'] = self.budget

        self.countstep = self.countstep + 1

        # Reward and ending

        done = self.countstep >= self.df.shape[0] or self.budget < ((500)+500*0.2*(self.countstep/7))

        if not done:
            self.state = self.df.iloc[self.countstep].to_numpy()
            #reward += 1
            #reward = 1 + self.budget/1000
        else:
            reward = 0
        #reward = self.result - (self.result * self.storagetime / 1400)
        reward = self.budget/1000
        self.allresults.append(reward)
        self.allbudget.append(self.budget)

        return self.state, reward, done, {}

    def render(self, mode='human'):
        pass


# Def agent DQN
class DQNAgent:
    def __init__(self, state_size, action_size):
        self.predicted_values = []
        self.state_size = state_size
        self.action_size = action_size
        self.memory = deque(maxlen=2000)
        self.gamma = 0.95  # Discount factor
        self.epsilon = 1.0  # Initial exploration rate
        self.epsilon_decay = 0.999  # Epsilon decrement factor
        self.epsilon_min = 0.001  # Minimum exploration rate
        self.learning_rate = 0.01  # Learning rate
        self.model = self._build_model()
        print(state_size, action_size)

    def _build_model(self):
        model = Sequential()
        model.add(Dense(24, input_dim=self.state_size, activation='relu'))
        model.add(Dense(24, activation='relu'))
        model.add(Dense(self.action_size, activation='linear'))
        model.compile(loss='mse', optimizer=Adam(lr=self.learning_rate))
        return model

    def remember(self, state, action, reward, next_state, done):
        self.memory.append((state, action, reward, next_state, done))

    def act(self, state):
        if np.random.rand() <= self.epsilon:
            return random.randrange(self.action_size)

        else:
            '''if type(state) is not tuple:
                state = state.reshape(1, -1)
            else:
                state = state[0]
                state = state.reshape(1, -1)'''

            state = np.array(state)
            state = state.reshape(1, -1)
            return np.argmax(self.model.predict(state))

    def replay(self, batch_size):
        if len(self.memory) < batch_size:
            return
        minibatch = random.sample(self.memory, batch_size)
        for state, action, reward, next_state, done in minibatch:
            target = reward
            if not done:
                next_state = next_state.reshape(1, -1)
                target = reward + self.gamma * np.amax(self.model.predict(next_state)[0])
            #print(target, reward)
            '''if type(state) is not tuple:
                state = state.reshape(1, -1)
            else:
                state = state[0]
                state = state.reshape(1, -1)'''
            #print(state)
            #print(state[0])
            state = state.reshape(1, -1)

            target_f = self.model.predict(state)
            b = target_f[0]

            self.predicted_values.append(b[0])

            target_f[0][action] = target

            self.model.fit(state, target_f, epochs=1, verbose=0)

        if self.epsilon > self.epsilon_min:
            self.epsilon *= self.epsilon_decay


# Enviroment
env = CustomEnv()

state_size = env.observation_space.shape[0]
action_size = env.action_space.n

#print(state_size)
#print(action_size)

agent = DQNAgent(state_size, action_size)

# Trening agenta DQN
num_episodes = 100
batch_size = 32

for episode in range(num_episodes):
    state = env.reset()
    #state = np.reshape(state, [1, state_size])
    done = False
    total_reward = 0

    while not done:
        action = agent.act(state)
        #print('akcja:', action)
        next_state, reward, done, _ = env.step(action)
        #next_state = np.reshape(next_state, [1, state_size])

        agent.remember(state, action, reward, next_state, done)
        state = next_state
        total_reward += reward
        #print('nagroda:', total_reward)

    print(f"Epizod {episode + 1}: Reward = {total_reward}")
    env.his.to_csv('his.csv')
    #print(max(env.allbudget))
    #print(env.allbudget[-1])
    if len(agent.memory) > batch_size:
        agent.replay(batch_size)
