# IMPORT_ASSETS.ps1 — 把 _staging\ 里的人工下载图归档到项目资产目录
# 用法：把下载的图片放入 D:\AI-Game-Factory\assets\_staging\，然后运行本脚本。
# 规则：manifest 命中 → 归档；目标哈希相同 → 去重跳过；目标哈希不同 → 进 conflicts\ 不覆盖；
#       批次自动命名图(a_wide_*/imagegen*) → 进 unclassified\ 等人工判定；未知文件 → 留在原地并警告。
$ErrorActionPreference = 'Stop'
$root = 'D:\AI-Game-Factory\assets'
$staging = Join-Path $root '_staging'
$conflicts = Join-Path $staging 'conflicts'
$unclassified = Join-Path $staging 'unclassified'
foreach ($d in @($conflicts, $unclassified)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }

$manifest = @{
    '赤雀_麻将群英传奇.png'                 = 'M001_Project_Sparrow\key_art'
    '赤雀王牌_牌局之外.png'                  = 'M001_Project_Sparrow\key_art'
    '白鶴天才_赤雀角色卡.png'                = 'M001_Project_Sparrow\characters'
    '赤雀小麦_麻将新星_poster.png'            = 'M001_Project_Sparrow\characters'
    '赤雀小麦_麻将新星_角色卡.png'            = 'M001_Project_Sparrow\characters'
    '赤雀计划_coach_k传奇麻将卡片.png'        = 'M001_Project_Sparrow\characters'
    '赤雀王牌_绯角色卡.png'                   = 'M001_Project_Sparrow\characters'
    '赤雀麻将风暴_群雄竞技海报.png'            = 'M001_Project_Sparrow\key_art'
    '赤雀_世界麻将联盟_阵营地图.png'           = 'M001_Project_Sparrow\factions'
    '白鹤秘境_project_sparrow.png'            = 'M001_Project_Sparrow\factions'
    '雀影新手的华丽一击.png'                  = 'M001_Project_Sparrow\characters'
    '余烬与传承_终末群像.png'                 = 'G002_Project_Legacy\key_art'
    '余烬与传承_铁誓之盾.png'                 = 'G002_Project_Legacy\factions'
    '赤胤剑姬_余烬与传承.png'                 = 'G002_Project_Legacy\characters'
    '圣辉先知_教堂圣女角色海报.png'            = 'G002_Project_Legacy\characters'
    '暗影蛊术师_余烬与传承.png'               = 'G002_Project_Legacy\characters'
    '赤月蛊巫_遗世王座.png'                   = 'G002_Project_Legacy\characters'
    '赤月之下的剑之继承者.png'                 = 'G002_Project_Legacy\characters'
    '暗月王座下的血色遗产.png'                 = 'G002_Project_Legacy\factions'
    '双项目_八人角色总览.png'                  = 'shared'
}

$moved = 0; $dup = 0; $conf = 0; $unc = 0; $unk = 0
Get-ChildItem -Path $staging -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg|webp|gif)$' } | ForEach-Object {
    $name = $_.Name
    $dest = $null
    if ($manifest.ContainsKey($name)) {
        $dest = $manifest[$name]
    } elseif ($name -match '^(a_wide_|imagegen)') {
        $dest = 'unclassified'
        $unc++
        Write-Output "批次命名图（需人工看图判定归属）：$name → unclassified\"
    } else {
        $unk++
        Write-Warning "未知文件 $name（不在 manifest，也不像批次命名）：留在 _staging 待人工登记到 docs/ASSET_INDEX.md"
        return
    }
    $dir = if ($dest -eq 'unclassified') { $unclassified } else { Join-Path $root $dest }
    $target = Join-Path $dir $name
    $srcHash = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash
    if (Test-Path -LiteralPath $target) {
        $dstHash = (Get-FileHash -Path $target -Algorithm SHA256).Hash
        if ($dstHash -eq $srcHash) { $dup++; Remove-Item -LiteralPath $_.FullName; Write-Output "去重跳过（哈希相同）：$name"; return }
        $alt = Join-Path $conflicts ($name -replace '\.([a-z0-9]+)$', '_alt.$1')
        $n = 2
        while (Test-Path -LiteralPath $alt) { $alt = Join-Path $conflicts ($name -replace '\.([a-z0-9]+)$', ('_alt' + [string]$n + '.$1')); $n++ }
        Move-Item -LiteralPath $_.FullName -Destination $alt; $conf++
        Write-Output "冲突（目标已有不同版本，不覆盖）：$name → conflicts\"
        return
    }
    Move-Item -LiteralPath $_.FullName -Destination $target
    if ($dest -ne 'unclassified') { $moved++; Write-Output "归档：$name → $dest\" }
}
Write-Output "完成：归档 $moved，去重 $dup，冲突 $conf，待人工 $unc，未知留存 $unk"
Write-Output '请更新 docs/ASSET_INDEX.md 的导入状态列（PENDING_IMPORT → IMPORTED）。'
