local Scheduler = require "Mortis/Core/Scheduler"

Scheduler.reset()
local zombie = {}
assert(Scheduler.shouldRun(zombie, "critical") == true)
assert(Scheduler.shouldRun(zombie, "dormant") == false)
Scheduler.configureBudget("nightfall-paths", 2)
assert(Scheduler.consumeBudget("nightfall-paths", 1))
assert(not Scheduler.consumeBudget("nightfall-paths", 2))

local report = Scheduler.getDiagnostics()
assert(report.classes.critical.considered == 1 and report.classes.critical.ran == 1)
assert(report.classes.dormant.considered == 1 and report.classes.dormant.deferred == 1)
assert(report.budgets["nightfall-paths"].accepted == 1)
assert(report.budgets["nightfall-paths"].deferred == 1)
assert(report.budgets["nightfall-paths"].acceptedUnits == 1)
assert(report.budgets["nightfall-paths"].deferredUnits == 2)

report.classes.critical.ran = 999
assert(Scheduler.getDiagnostics().classes.critical.ran == 1, "diagnostics must return a protected snapshot")

Scheduler.reset()
assert(next(Scheduler.getDiagnostics().classes) == nil)
print("Project M.O.R.T.I.S. scheduler diagnostic checks passed")
