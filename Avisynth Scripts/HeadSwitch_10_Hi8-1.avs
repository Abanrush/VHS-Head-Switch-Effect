# === СУБПИКСЕЛЬНЫЙ СДВИГ ===
function HShiftSub(clip c, float off) {
    w = c.Width
    h = c.Height
    pad = Floor(w * 0.01)  # Запас черного с противоположной стороны
    c = c.AddBorders(pad, 0, pad, 0)
    src_x = pad - off  # Сдвиг слева "-", сдвиг справа "+"
    return c.BilinearResize(w, h, src_x, 0, src_x + w, h)
}

# === ЗАГРУЗКА И ПОДГОТОВКА ИСХОДНОГО ВИДЕО ===
src = FFMPEGSource2("input.mp4", atrack=1)  # Input2.mp4 - исходное видео, atrack=1 - использовать 1-ю аудиодорожку, если звук отсутствует, то полностью убрать atrack=1
src = src.ConvertToYUY2()

head_switch = src.ScriptClip("""
    w = Width
    h = Height
    t = current_frame
    fps_ratio = 24.0 / framerate  # Привязка частоты анимации к 24 FPS, независимо от исходного FPS видео

    # === ВЫСОТА ПОЛОС (в процентах от общей высоты кадра) ===
    strip_height_percent = 1.4
    
    # == РАСЧЁТ ИТОГОВОЙ ВЫСОТЫ ==
    total_strip_height = Floor(h * strip_height_percent / 100.0)  # 720 * 1.4 / 100 ≈ 10 px
    #total_strip_height = Max(2, Min(total_strip_height, h/3))
    #total_strip_height = (total_strip_height % 2 != 0) ? total_strip_height - 1 : total_strip_height

    # === ДРОЖАНИЕ / РАЗДВОЕНИЕ  (имитация Yadif 2x) ===
    rapid_shift = (t % 2 == 0) ? (w * 0.2 / 100.0) : 0.0

    # === ФИКСИРОВАННЫЙ СДВИГ ===
    shift_right_percent = 2.5
    extra_shift = w * shift_right_percent / 100.0

    # === ГЕНЕРАТОР ВСПЛЕСКОВ ===
    raw_noise = Sin(t * 0.117 * fps_ratio) + Cos(t * 0.383 * fps_ratio) + Sin(t * 0.691 * fps_ratio) + Cos(t * 1.037 * fps_ratio)
    norm_noise = (raw_noise + 4.0) / 8.0
    
    # === ЧАСТОТА ВСПЛЕСКОВ ===
    burst_thresh = 0.01  # Чем меньше значение, тем чаще всплески
    burst_raw = Max(0, norm_noise - burst_thresh) / (1.0 - burst_thresh)
    burst_intensity = Pow(burst_raw, 0.5)

    # === ВЕКТОР НАПРАВЛЕНИЯ ВСПЛЕСКА ===
    dir = Sin(t * 1.37 * fps_ratio) # Фаза колебаний сдвига
    
    # === ДИАПАЗОН ВСПЛЕСКА ПОЛОС ===
    base_min = w * 0.5 / 100.0   # Минимальное значение (1.5% ширины)
    base_max = w * 1.0 / 100.0   # Максимальное значение (2.0% ширины)
    base_center = (base_min + base_max) / 2.0  # Средняя точка диапазона
    base_amp    = (base_max - base_min) / 2.0  # Амплитуда колебаний вокруг средней точки
    
    # === ИТОГОВЫЙ СДВИГ ===
    #global_off = ((base_center + base_amp * dir) * burst_intensity) + extra_shift  # Для видео в 24-30 FPS
    global_off = rapid_shift + ((base_center + base_amp * dir) * burst_intensity) + extra_shift  # Для видео в 48-60 FPS

    # === ДЕЛЕНИЕ НА ПОЛОСЫ (1 полоса = 1 пиксель) ===
    base_h = 1
    total_base_h = 10  # количество полос

    # === ВЫРЕЗАНИЕ КАЖДОЙ ПОЛОСЫ СНИЗУ ВВЕРХ ===
    r1  = Crop(0, h - total_base_h, w, base_h)
    r2  = Crop(0, h - total_base_h + base_h, w, base_h)
    r3  = Crop(0, h - total_base_h + base_h*2, w, base_h)
    r4  = Crop(0, h - total_base_h + base_h*3, w, base_h)
    r5  = Crop(0, h - total_base_h + base_h*4, w, base_h)
    r6  = Crop(0, h - total_base_h + base_h*5, w, base_h)
    r7  = Crop(0, h - total_base_h + base_h*6, w, base_h)
    r8  = Crop(0, h - total_base_h + base_h*7, w, base_h)
    r9  = Crop(0, h - total_base_h + base_h*8, w, base_h)
    r10 = Crop(0, h - total_base_h + base_h*9, w, base_h)

    # === ИНДИВИДУАЛЬНЫЙ СДВИГ КАЖДОЙ ПОЛОСЫ ===
    jet = burst_intensity  # Интенсивность всплеска
    off1  = w * 3.0 / 100.0 + (w * 3.0 / 100.0 * jet) + global_off  # Самая верхняя полоса
    off2  = w * 2.9 / 100.0 + (w * 2.9 / 100.0 * jet) + global_off
    off3  = w * 1.8 / 100.0 + (w * 1.8 / 100.0 * jet) + global_off
    off4  = w * 1.7 / 100.0 + (w * 1.7 / 100.0 * jet) + global_off
    off5  = w * 1.1 / 100.0 + (w * 1.1 / 100.0 * jet) + global_off
    off6  = w * 1.0 / 100.0 + (w * 1.0 / 100.0 * jet) + global_off
    off7  = w * 0.1 / 100.0 + (w * 0.1 / 100.0 * jet) + global_off
    off8  = w * 0.0 / 100.0 + (w * 0.0 / 100.0 * jet) + global_off
    off9  = w * -1.5 / 100.0 + (w * -0.5 / 100.0 * jet) + global_off
    off10 = w * -1.6 / 100.0 + (w * -0.6 / 100.0 * jet) + global_off
/*
    # === ФИКСИРОВАННАЯ НАСЫЩЕННОСТЬ (30%) ===
    sat1 = 0.3
    sat2 = 0.3
    sat3 = 0.3
    sat4 = 0.3
    sat5 = 0.3
    sat6 = 0.3
    sat7 = 0.3
    sat8 = 0.3
    sat9 = 0.3
    sat10 = 0.3
*/
/*
    # === ДИНАМИЧЕСКАЯ НАСЫЩЕННОСТЬ (5% - 80%) ===
    sat1  = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 0.0) + Cos(t*0.71*fps_ratio + 0.0) + 2.0) / 4.0)))
    sat2  = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 0.4) + Cos(t*0.71*fps_ratio + 0.4) + 2.0) / 4.0)))
    sat3  = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 0.8) + Cos(t*0.71*fps_ratio + 0.8) + 2.0) / 4.0)))
    sat4  = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 1.2) + Cos(t*0.71*fps_ratio + 1.2) + 2.0) / 4.0)))
    sat5  = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 1.6) + Cos(t*0.71*fps_ratio + 1.6) + 2.0) / 4.0)))
    sat6  = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 2.0) + Cos(t*0.71*fps_ratio + 2.0) + 2.0) / 4.0)))
    sat7  = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 2.4) + Cos(t*0.71*fps_ratio + 2.4) + 2.0) / 4.0)))
    sat8  = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 2.8) + Cos(t*0.71*fps_ratio + 2.8) + 2.0) / 4.0)))
    sat9  = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 3.2) + Cos(t*0.71*fps_ratio + 3.2) + 2.0) / 4.0)))
    sat10 = Max(0.05, Min(0.80, 0.05 + 0.75 * ((Sin(t*0.23*fps_ratio + 3.6) + Cos(t*0.71*fps_ratio + 3.6) + 2.0) / 4.0)))
*/
    # === ДИНАМИЧЕСКАЯ НАСЫЩЕННОСТЬ (5% - 80%, но зависит от всплесков) ===
    sat_dyn = 0.05 + 0.75 * (1.0 - burst_intensity * 0.7)
    sat1 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))
    sat2 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))
    sat3 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))
    sat4 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))
    sat5 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))
    sat6 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))
    sat7 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))
    sat8 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))
    sat9 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))
    sat10 = Max(0.05, Min(0.80, sat_dyn * (0.9 + Sin(t*0.2)*0.1)))

    # === ПРИМЕНЕНИЕ СДВИГА С ДИНАМИЧЕСКОЙ НАСЫЩЕННОСТЬЮ ===
    r1  = HShiftSub(r1.Tweak(sat=sat1).ConvertToRGB24(), off1).ConvertToYUY2()
    r2  = HShiftSub(r2.Tweak(sat=sat2).ConvertToRGB24(), off2).ConvertToYUY2()
    r3  = HShiftSub(r3.Tweak(sat=sat3).ConvertToRGB24(), off3).ConvertToYUY2()
    r4  = HShiftSub(r4.Tweak(sat=sat4).ConvertToRGB24(), off4).ConvertToYUY2()
    r5  = HShiftSub(r5.Tweak(sat=sat5).ConvertToRGB24(), off5).ConvertToYUY2()
    r6  = HShiftSub(r6.Tweak(sat=sat6).ConvertToRGB24(), off6).ConvertToYUY2()
    r7  = HShiftSub(r7.Tweak(sat=sat7).ConvertToRGB24(), off7).ConvertToYUY2()
    r8  = HShiftSub(r8.Tweak(sat=sat8).ConvertToRGB24(), off8).ConvertToYUY2()
    r9  = HShiftSub(r9.Tweak(sat=sat9).ConvertToRGB24(), off9).ConvertToYUY2()
    r10 = HShiftSub(r10.Tweak(sat=sat10).ConvertToRGB24(), off10).ConvertToYUY2()

    # === СБОРКА ВСЕХ ПОЛОС И МАСШТАБИРОВАНИЕ ДО РАСЧЁТНОЙ ВЫСОТЫ ===
    bottom_glitch_10 = StackVertical(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10)
    bottom_glitch = bottom_glitch_10.BilinearResize(w, total_strip_height)
    
    # === ЗАМЕНА НИЖНЕЙ ЧАСТИ КАДРА НА ГОТОВУЮ ПОЛОСУ ===
    StackVertical(Crop(0, 0, w, h - total_strip_height), bottom_glitch)
""")

return head_switch