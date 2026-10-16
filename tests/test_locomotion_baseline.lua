local authority=true
package.loaded['Mortis/Runtime/Authority']={canWriteCanonicalState=function()return authority end}
IsoZombie={getSpeedTypeFromWalkType=function(walk)return walk:sub(1,6)=='sprint' and 1 or walk:sub(1,4)=='fast' and 2 or 3 end}
local function entity()
 local z={walk='fast2',speedType=2,speedMod=0.734,crawler=false,crawlerType=1,writes=0}
 function z:getWalkType()return self.walk end
 function z:getSpeedType()return self.speedType end
 function z:getSpeedMod()return self.speedMod end
 function z:isCrawling()return self.crawler end
 function z:getCrawlerType()return self.crawlerType end
 function z:setWalkType(v)self.writes=self.writes+1;self.walk=v end
 function z:setSpeedTypeFromWalkType()self.writes=self.writes+1;self.speedType=IsoZombie.getSpeedTypeFromWalkType(self.walk)end
 function z:setSpeedMod(v)self.writes=self.writes+1;self.speedMod=v end
 function z:setCrawler(v)self.writes=self.writes+1;self.crawler=v end
 function z:setCrawlerType(v)self.writes=self.writes+1;self.crawlerType=v end
 return z
end
local Baseline=require 'Mortis/Runtime/LocomotionBaseline'
local z=entity()
local original=assert(Baseline.capture(z))
assert(z.writes==0 and original.crawler==false)
z.walk='sprint1';z.speedType=1;z.speedMod=2;z.crawler=true;z.crawlerType=3
assert(Baseline.restore(z,original))
assert(z.walk=='fast2' and z.speedType==2 and z.speedMod==0.734 and z.crawler==false and z.crawlerType==1)
local count=z.writes
assert(Baseline.restore(z,original) and z.writes==count,'already-restored fields must not be written again')
authority=false
assert(not Baseline.capture(z) and not Baseline.restore(z,original) and z.writes==count)
authority=true
local bad=entity();bad.speedMod=0/0
assert(not Baseline.capture(bad) and bad.writes==0)
bad=entity();bad.speedType=1
assert(not Baseline.capture(bad),'inconsistent walk/class baseline cannot be reconstructed safely')
bad=entity();bad.setSpeedMod=false
assert(not Baseline.capture(bad),'capture must preflight the inverse setters')
bad=entity();bad.setSpeedMod=function(self)self.writes=self.writes+1 end;bad.speedMod=2
assert(not Baseline.restore(bad,original),'ignored native setters must fail readback')
assert(Baseline.restore(entity(),original),'a failed restore must not mutate its retry input')
assert(not Baseline.restore(entity(),{version=1,crawler=false,speedMod=1,walkType='fast2',speedType=2}),
 'incomplete saved baseline must reject before native writes')
print('Observed locomotion capture, exact readback, nil/false, retry and authority tests passed')
