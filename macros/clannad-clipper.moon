export script_name        = "Clannad clipper"
export script_description = "Nazaki's dumb clannad clip bullshit"
export script_version     = "0.6.0"

CLIPS = {
    false, -- edit this into a clip tag block as below if you want to insert something on the first frame too
    [[{\clip(m 319 0 l 321 0 321 1080 319 1080 m 372 0 l 374 0 374 1080 372 1080)}]],
    [[{\clip(m 316 0 l 323 0 323 1080 316 1080 m 370 0 l 375 0 375 1080 370 1080 m 424 0 l 428 0 428 1080 424 1080 m 478 0 l 481 0 481 1080 478 1080 m 532 0 l 534 0 534 1080 532 1080 m 586 0 l 587 0 587 1080 586 1080)}]],
    [[{\clip(m 312 0 l 326 0 326 1080 312 1080 m 367 0 l 378 0 378 1080 367 1080 m 421 0 l 431 0 431 1080 421 1080 m 476 0 l 483 0 483 1080 476 1080 m 530 0 l 536 0 536 1080 530 1080 m 584 0 l 588 0 588 1080 584 1080 m 638 0 l 641 0 641 1080 638 1080 m 692 0 l 694 0 694 1080 692 1080 m 746 0 l 747 0 747 1080 746 1080 m 799 0 l 800 0 800 1080 799 1080)}]],
    [[{\clip(m 307 0 l 331 0 331 1080 307 1080 m 362 0 l 383 0 383 1080 362 1080 m 417 0 l 434 0 434 1080 417 1080 m 472 0 l 486 0 486 1080 472 1080 m 527 0 l 539 0 539 1080 527 1080 m 581 0 l 591 0 591 1080 581 1080 m 636 0 l 643 0 643 1080 636 1080 m 690 0 l 695 0 695 1080 690 1080 m 744 0 l 748 0 748 1080 744 1080 m 798 0 l 801 0 801 1080 798 1080 m 852 0 l 854 0 854 1080 852 1080 m 906 0 l 907 0 907 1080 906 1080 m 959 0 l 960 0 960 1080 959 1080)}]],
    [[{\clip(m 302 0 l 336 0 336 1080 302 1080 m 357 0 l 388 0 388 1080 357 1080 m 412 0 l 439 0 439 1080 412 1080 m 467 0 l 491 0 491 1080 467 1080 m 522 0 l 543 0 543 1080 522 1080 m 577 0 l 595 0 595 1080 577 1080 m 632 0 l 647 0 647 1080 632 1080 m 686 0 l 699 0 699 1080 686 1080 m 741 0 l 751 0 751 1080 741 1080 m 795 0 l 803 0 803 1080 795 1080 m 850 0 l 856 0 856 1080 850 1080 m 904 0 l 908 0 908 1080 904 1080 m 958 0 l 961 0 961 1080 958 1080 m 1012 0 l 1014 0 1014 1080 1012 1080 m 1066 0 l 1067 0 1067 1080 1066 1080 m 1119 0 l 1120 0 1120 1080 1119 1080)}]],
    [[{\clip(m 296 0 l 342 0 342 1080 296 1080 m 351 0 l 394 0 394 1080 351 1080 m 406 0 l 445 0 445 1080 406 1080 m 461 0 l 496 0 496 1080 461 1080 m 517 0 l 548 0 548 1080 517 1080 m 572 0 l 599 0 599 1080 572 1080 m 627 0 l 651 0 651 1080 627 1080 m 682 0 l 703 0 703 1080 682 1080 m 737 0 l 755 0 755 1080 737 1080 m 792 0 l 807 0 807 1080 792 1080 m 846 0 l 859 0 859 1080 846 1080 m 901 0 l 911 0 911 1080 901 1080 m 955 0 l 963 0 963 1080 955 1080 m 1080 0 l 1016 0 1016 1080 1080 1080 m 1064 0 l 1068 0 1068 1080 1064 1080 m 1118 0 l 1121 0 1121 1080 1118 1080 m 1172 0 l 1174 0 1174 1080 1172 1080 m 1226 0 l 1227 0 1227 1080 1226 1080 m 1279 0 l 1280 0 1280 1080 1279 1080)}]],
    [[{\clip(m 308 0 l 399 0 399 1080 308 1080 m 401 0 l 451 0 451 1080 401 1080 m 456 0 l 502 0 502 1080 456 1080 m 511 0 l 554 0 554 1080 511 1080 m 566 0 l 605 0 605 1080 566 1080 m 621 0 l 657 0 657 1080 621 1080 m 677 0 l 708 0 708 1080 677 1080 m 732 0 l 760 0 760 1080 732 1080 m 787 0 l 811 0 811 1080 787 1080 m 842 0 l 863 0 863 1080 842 1080 m 897 0 l 915 0 915 1080 897 1080 m 951 0 l 967 0 967 1080 951 1080 m 1006 0 l 1019 0 1019 1080 1006 1080 m 1061 0 l 1071 0 1071 1080 1061 1080 m 1115 0 l 1123 0 1123 1080 1115 1080 m 1170 0 l 1176 0 1176 1080 1170 1080 m 1224 0 l 1228 0 1228 1080 1224 1080 m 1278 0 l 1281 0 1281 1080 1278 1080 m 1332 0 l 1334 0 1334 1080 1332 1080 m 1386 0 l 1387 0 1387 1080 1386 1080)}]],
    [[{\clip(m 308 0 l 559 0 559 1080 308 1080 m 561 0 l 611 0 611 1080 561 1080 m 615 0 l 663 0 663 1080 615 1080 m 671 0 l 714 0 714 1080 671 1080 m 726 0 l 766 0 766 1080 726 1080 m 781 0 l 817 0 817 1080 781 1080 m 836 0 l 868 0 868 1080 836 1080 m 892 0 l 920 0 920 1080 892 1080 m 947 0 l 972 0 972 1080 947 1080 m 1002 0 l 1023 0 1023 1080 1002 1080 m 1057 0 l 1075 0 1075 1080 1057 1080 m 1111 0 l 1127 0 1127 1080 1111 1080 m 1166 0 l 1179 0 1179 1080 1166 1080 m 1221 0 l 1231 0 1231 1080 1221 1080 m 1275 0 l 1283 0 1283 1080 1275 1080 m 1330 0 l 1336 0 1336 1080 1330 1080 m 1384 0 l 1388 0 1388 1080 1384 1080 m 1438 0 l 1441 0 1441 1080 1438 1080 m 1492 0 l 1494 0 1494 1080 1492 1080 m 1546 0 l 1547 0 1547 1080 1546 1080)}]],
    [[{\clip(m 308 0 l 719 0 719 1080 308 1080 m 721 0 l 771 0 771 1080 721 1080 m 775 0 l 823 0 823 1080 775 1080 m 830 0 l 874 0 874 1080 830 1080 m 886 0 l 925 0 925 1080 886 1080 m 941 0 l 977 0 977 1080 941 1080 m 996 0 l 1028 0 1028 1080 996 1080 m 1051 0 l 1080 0 1080 1080 1051 1080 m 1107 0 l 1131 0 1131 1080 1107 1080 m 1162 0 l 1183 0 1183 1080 1162 1080 m 1216 0 l 1235 0 1235 1080 1216 1080 m 1271 0 l 1287 0 1287 1080 1271 1080 m 1326 0 l 1339 0 1339 1080 1326 1080 m 1381 0 l 1391 0 1391 1080 1381 1080 m 1435 0 l 1444 0 1444 1080 1435 1080 m 1490 0 l 1496 0 1496 1080 1490 1080 m 1544 0 l 1548 0 1548 1080 1544 1080 m 1598 0 l 1601 0 1601 1080 1598 1080)}]],
    [[{\clip(m 308 0 l 879 0 879 1080 308 1080 m 881 0 l 932 0 932 1080 881 1080 m 935 0 l 983 0 983 1080 935 1080 m 990 0 l 1034 0 1034 1080 990 1080 m 1046 0 l 1086 0 1086 1080 1046 1080 m 1101 0 l 1137 0 1137 1080 1101 1080 m 1156 0 l 1188 0 1188 1080 1156 1080 m 1211 0 l 1240 0 1240 1080 1211 1080 m 1267 0 l 1291 0 1291 1080 1267 1080 m 1321 0 l 1343 0 1343 1080 1321 1080 m 1377 0 l 1395 0 1395 1080 1377 1080 m 1431 0 l 1447 0 1447 1080 1431 1080 m 1486 0 l 1499 0 1499 1080 1486 1080 m 1541 0 l 1551 0 1551 1100 1541 1100 m 1596 0 l 1603 0 1603 1080 1596 1080)}]],
    [[{\clip(m 308 0 l 1092 0 1092 1080 308 1080 m 1095 0 l 1144 0 1144 1080 1095 1080 m 1150 0 l 1194 0 1194 1080 1150 1080 m 1206 0 l 1246 0 1246 1080 1206 1080 m 1261 0 l 1297 0 1297 1080 1261 1080 m 1316 0 l 1349 0 1349 1080 1316 1080 m 1371 0 l 1400 0 1400 1080 1371 1080 m 1426 0 l 1452 0 1452 1080 1426 1080 m 1481 0 l 1503 0 1503 1080 1481 1080 m 1537 0 l 1555 0 1555 1080 1537 1080 m 1592 0 l 1607 0 1607 1080 1592 1080)}]],
    [[{\clip(m 308 0 l 1252 0 1252 1080 308 1080 m 1255 0 l 1303 0 1303 1080 1255 1080 m 1310 0 l 1354 0 1354 1080 1310 1080 m 1365 0 l 1406 0 1406 1080 1365 1080 m 1421 0 l 1457 0 1457 1080 1421 1080 m 1476 0 l 1509 0 1509 1080 1476 1080 m 1531 0 l 1560 0 1560 1080 1531 1080 m 1586 0 l 1611 0 1611 1080 1586 1080)}]],
    [[{\clip(m 308 0 l 1412 0 1412 1080 308 1080 m 1415 0 l 1463 0 1463 1080 1415 1080 m 1470 0 l 1515 0 1515 1080 1470 1080 m 1525 0 l 1566 0 1566 1080 1525 1080 m 1581 0 l 1617 0 1617 1080 1581 1080)}]],
    [[{\clip(m 308 0 l 1572 0 1572 1080 308 1080 m 1575 0 l 1623 0 1623 1080 1575 1080)}]],
}

msff = aegisub.ms_from_frame
ffms = aegisub.frame_from_ms

main = (sub, sel, iclips) ->
    -- for each selected line
    --   fbf first 15 frames
    --   leave out first, apply clips to rest
    --   leave end otherwise untouched
    -- if "iclips" is set, output iclips instead (for fade-out)

    for i = #sel, 1, -1
        line = sub[sel[i]]
        text = line.text

        local start_f
        -- write out the rest of the line first
        -- in normal mode, that's N frames after start
        -- in iclips mode, that's until N frames from end
        unless iclips
            start_f = ffms line.start_time
            line.start_time = msff start_f + #CLIPS
        else
            start_f = -#CLIPS + ffms line.end_time
            line.end_time = msff start_f
        sub[sel[i]] = line

        -- then do clips
        -- this inserts everything _before_ the main line, which is a bit silly with the fade-out version, but _oh well_
        for j = #CLIPS, 1, -1
            clip = CLIPS[j]
            continue unless clip or iclips --skip blank, if "fading in"
            clip = clip\gsub("clip", "iclip") if iclips and clip

            line.start_time = msff start_f + j - 1
            line.end_time = msff start_f + j
            line.text = (clip or "") .. text

            sub[-sel[i]] = line

clips = (sub, sel) -> main sub, sel, false
iclips = (sub, sel) -> main sub, sel, true

aegisub.register_macro script_name .. "/clip (fadein)", script_description, clips
aegisub.register_macro script_name .. "/iclip (fadeout)", script_description, iclips
