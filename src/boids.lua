-- https://processing.org/examples/flocking.html
Boid = {}
function Boid:new(sprite, x, y)
  local angle = flr(rnd()*360)
  obj = {
    sprite_id = sprite,
    position = Vec:new(x, y),
    velocity = Vec:new(cos(angle), sin(angle)),
    acceleration = Vec:new(0, 0),
    r = 2,
    max_speed = 1,
    max_force = 0.03,
    desired_sep = 15,
    neighbor_dist = 30,
    -- internal
    tick = 0,
    max_ticks = 10
  }
  setmetatable(obj, self)
  self.__index = self
  return obj
end
function Boid:update()
  self.velocity = Vec.limit(self.velocity + self.acceleration, self.max_speed)
  self.position += self.velocity
  self.acceleration *= 0
end
function Boid:seek(target)
  local desired = target - self.position
  local desired_norm = Vec.normalize(desired)
  desired *= self.max_speed
  return Vec.limit(desired - self.velocity, self.max_force)
end
function Boid:draw()
  local pos = lerp(self.position, self.position + Vec.limit(self.velocity + self.acceleration, self.max_speed), self.tick/self.max_ticks)
  spr(self.sprite_id, pos.x, pos.y, 2, 2)
  -- draw_sprite_rotated(2, self.position, 16, Vec.heading(self.velocity))
end
function Boid:border()
  if (self.position.x < 0) self.position.x = 127
  if (self.position.y < 0) self.position.y = 127
  if (self.position.x > 127) self.position.x = 0
  if (self.position.y > 127) self.position.y = 0
end
function Boid:flock(boids)
  local sep = Boid.separate(self, boids)
  local ali = Boid.align(self, boids)
  local coh = Boid.cohesion(self, boids)

  sep *= 1.5

  self.acceleration += sep
  self.acceleration += ali
  self.acceleration += coh
end
function Boid:separate(boids)
  local steer = Vec:new(0, 0)
  local count = 0

  for other in all(boids) do 
    local dist = distance(self.position, other.position)
    if dist > 0 and dist < self.desired_sep then 
      local diff = self.position - other.position
      diff = Vec.normalize(diff)
      diff /= dist 
      steer += diff 
      count += 1 
    end
  end

  if count > 0 then 
    steer /= count 
  end

  if Vec.magnitude(steer) > 0 then 
    steer = Vec.normalize(steer)
    steer *= self.max_speed
    steer -= self.velocity
    steer = Vec.limit(steer, self.max_force)
  end

  return steer
end
function Boid:align(boids)
  local sum = Vec:new(0, 0)
  local count = 0

  for boid in all(boids) do
    local dist = distance(self.position, boid.position)

    if dist > 0 and dist < self.neighbor_dist then 
      sum += boid.velocity
      count += 1
    end
  end

  if count > 0 then 
    sum /= count 
    sum = Vec.normalize(sum)
    sum *= self.max_speed
    return Vec.limit(sum - self.velocity, self.max_force)
  else
    return Vec:new(0, 0)
  end
end
function Boid:cohesion(boids)
  local sum = Vec:new(0, 0)
  local count = 0

  for boid in all(boids) do 
    local dist = distance(self.position, boid.position)
    if dist > 0 and dist < self.neighbor_dist then 
      sum += boid.position
      count += 1
    end
  end

  if count > 0 then 
    sum /= count 
    return Boid.seek(self, sum)
  else
    return Vec:new(0, 0)
  end
end

function run(boids)
  for boid in all(boids) do 
    boid.tick = (boid.tick + 1) % boid.max_ticks
    if boid.tick == 0 then
      Boid.flock(boid, boids)
      Boid.update(boid)
      Boid.border(boid)
      Boid.draw(boid)
    end
  end
end
