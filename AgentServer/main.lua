------------------------------------------------------
---! @file
---! @brief AgentServer的启动文件
------------------------------------------------------

---! 依赖
local skynet  = require "skynet"
local cluster = require "skynet.cluster"

---! 服务的启动函数
skynet.start(function()
    ---! 初始化随机数
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

    ---! 启动NodeInfo
    local srv = skynet.uniqueservice("NodeInfo")
    local cfg = skynet.call(srv, "lua", "initNode")

    ---! 启动console服务
    if not skynet.getenv "daemon" then
        skynet.newservice("Console")
    end

    ---! 启动DebugConsole服务
    local port = checkint(ttd.express_query(cfg, "nodeInfo", "debugPort"))
    if port > 0 then
        skynet.newservice("DebugConsole", port)
    end

    ---! 集群处理
    local list = ttd.express_query(cfg, "clusterList")
    cluster.reload(list)

    local appName = ttd.express_query(cfg, "nodeInfo", "appName")
    cluster.open(appName)

    ---! 启动 NodeStat 服务
    skynet.uniqueservice("NodeStat")

    ---! 启动 NodeLink 服务
    skynet.newservice("NodeLink")

    ---! 启动 ClientAuth 服务
    skynet.uniqueservice("ClientAuth")

    ---! 启动 WatchDog 服务
    skynet.uniqueservice("WatchDog")

    ---! 启动好了，没事做就退出
    skynet.exit()
end)
