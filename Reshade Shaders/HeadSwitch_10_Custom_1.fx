// ============================================================================
// Head Switch Custom #1
// ============================================================================

#include "ReShade.fxh"

uniform float Time < source = "timer"; >;

#define NUM_STRIPES 10

// ============================================================================
// ГЛОБАЛЬНЫЕ ПАРАМЕТРЫ
// ============================================================================

// --- ВЫСОТА ЭФФЕКТА ---
uniform float StripHeightPercent <
    ui_type = "slider";
    ui_label = "Strip Height";
    ui_tooltip = "The percentage of screen height where the effect occurs";
    ui_category = "Global Settings";
    ui_step = 0.01; ui_min = 0.1; ui_max = 100.0;
> = 1.40;

// --- РАЗДВОЕНИЕ / ИМИТАЦИЯ Yadif 2x ---
uniform float RapidShift <
    ui_type = "slider";
    ui_label = "Yadif 2x";
    ui_tooltip = "Simulates the rapid left and right shifting of stripes, as in the Yadif 2x algorithm";
    ui_category = "Global Settings";
    ui_step = 0.1; ui_min = -1.0; ui_max = 1.0;
> = 0.2;

// --- ФИКСИРОВАННЫЙ СДВИГ ---
uniform float ExtraShiftPercent <
    ui_type = "slider";
    ui_label = "Right Shift";
    ui_tooltip = "Fixed shift of the entire effect area to the right";
    ui_category = "Global Settings";
    ui_step = 0.01; ui_min = 0.0; ui_max = 10.0;
> = 2.5;

// --- ЧАСТОТА ВСПЛЕСКОВ ---
uniform float BurstFrequency <
    ui_type = "slider";
    ui_label = "Burst Frequency";
    ui_tooltip = "The smaller it is, the more often strong surges occur";
    ui_category = "Global Settings";
    ui_step = 0.005; ui_min = 0.0; ui_max = 0.5;
> = 0.01;

// --- СИЛА ВСПЛЕСКА ---
uniform float BurstPower <
    ui_type = "slider";
    ui_label = "Burst Power";
    ui_category = "Global Settings";
    ui_step = 0.1; ui_min = 0.0; ui_max = 5.0;
> = 0.5;

// --- ДИАПАЗОН ВСПЛЕСКА (мин. значение) ---
uniform float BurstMinPercent <
    ui_type = "slider";
    ui_label = "Min. Burst Spread";
    ui_category = "Global Settings";
    ui_step = 0.1; ui_min = 0.0; ui_max = 5.0;
> = 0.5;

// --- ДИАПАЗОН ВСПЛЕСКА (макс. значение) ---
uniform float BurstMaxPercent <
    ui_type = "slider";
    ui_label = "Max. Burst Spread";
    ui_category = "Global Settings";
    ui_step = 0.1; ui_min = 0.0; ui_max = 5.0;
> = 1.0;

// --- СКОРОСТЬ ЭФФЕКТА ---
uniform float TimerSpeedMultiplier <
    ui_type = "slider";
    ui_label = "Effect Speed";
    ui_tooltip = "Effect speed, 1.0 - speed as in a 24 fps video";
    ui_category = "Global Settings";
    ui_step = 0.1; ui_min = 0.1; ui_max = 5.0;
> = 1.0;

uniform int SEED <
    ui_label = "Random Seed";
    ui_category = "Global Settings";
> = 42;

// ============================================================================
// ПЕРЕКЛЮЧАТЕЛЬ РЕЖИМА НАСЫЩЕННОСТИ
// ============================================================================

uniform bool USE_DYNAMIC_SAT <
    ui_category = "Saturation Mode";
    ui_label = "Use Dynamic Saturation";
    ui_tooltip = "Dynamic saturation depends on the bursts";
> = true;

// ============================================================================
// ФИКСИРОВАННАЯ НАСЫЩЕННОСТЬ
// ============================================================================

uniform float FIXED_SAT <
    ui_category = "Fixed Saturation";
    ui_type = "slider";
    ui_label = "Fixed Saturation";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.01;
    ui_tooltip = "Ignore when Dynamic Saturation is enabled";
> = 0.3;

// ============================================================================
// ДИНАМИЧЕСКАЯ НАСЫЩЕННОСТЬ
// ============================================================================

uniform float DynSat_Min <
    ui_category = "Dynamic Saturation";
    ui_type = "slider";
    ui_label = "Min Saturation";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.01;
> = 0.05;

uniform float DynSat_Max <
    ui_category = "Dynamic Saturation";
    ui_type = "slider";
    ui_label = "Max Saturation";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.01;
> = 0.80;

uniform float DynSat_BurstInfluence <
    ui_category = "Dynamic Saturation";
    ui_type = "slider";
    ui_label = "Burst Influence";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.01;
    ui_tooltip = "Percentage of influence of bursts on saturation";
> = 0.7;

uniform float DynSat_Fluc <
    ui_category = "Dynamic Saturation";
    ui_type = "slider";
    ui_label = "Saturation Fluctuation";
    ui_min = 0.0;
    ui_max = 0.5;
    ui_step = 0.01;
    ui_tooltip = "The strength of random saturation fluctuations";
> = 0.1;

// ============================================================================
// ИНДИВИДУАЛЬНЫЕ НАСТРОЙКИ ПОЛОС
// ============================================================================

// --- STRIPE 0 ---
uniform float Stripe0_BaseOff <
    ui_category = "Stripe 0";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.026;

uniform float Stripe0_JetMult <
    ui_category = "Stripe 0";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.026;

uniform float Stripe0_SatMult <
    ui_category = "Stripe 0";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// --- STRIPE 1 ---
uniform float Stripe1_BaseOff <
    ui_category = "Stripe 1";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.025;

uniform float Stripe1_JetMult <
    ui_category = "Stripe 1";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.025;

uniform float Stripe1_SatMult <
    ui_category = "Stripe 1";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// --- STRIPE 2 ---
uniform float Stripe2_BaseOff <
    ui_category = "Stripe 2";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.024;

uniform float Stripe2_JetMult <
    ui_category = "Stripe 2";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.024;

uniform float Stripe2_SatMult <
    ui_category = "Stripe 2";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// --- STRIPE 3 ---
uniform float Stripe3_BaseOff <
    ui_category = "Stripe 3";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.023;

uniform float Stripe3_JetMult <
    ui_category = "Stripe 3";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.023;

uniform float Stripe3_SatMult <
    ui_category = "Stripe 3";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// --- STRIPE 4 ---
uniform float Stripe4_BaseOff <
    ui_category = "Stripe 4";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.022;

uniform float Stripe4_JetMult <
    ui_category = "Stripe 4";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.022;

uniform float Stripe4_SatMult <
    ui_category = "Stripe 4";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// --- STRIPE 5 ---
uniform float Stripe5_BaseOff <
    ui_category = "Stripe 5";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.021;

uniform float Stripe5_JetMult <
    ui_category = "Stripe 5";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.021;

uniform float Stripe5_SatMult <
    ui_category = "Stripe 5";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// --- STRIPE 6 ---
uniform float Stripe6_BaseOff <
    ui_category = "Stripe 6";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.020;

uniform float Stripe6_JetMult <
    ui_category = "Stripe 6";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.020;

uniform float Stripe6_SatMult <
    ui_category = "Stripe 6";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// --- STRIPE 7 ---
uniform float Stripe7_BaseOff <
    ui_category = "Stripe 7";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.019;

uniform float Stripe7_JetMult <
    ui_category = "Stripe 7";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.019;

uniform float Stripe7_SatMult <
    ui_category = "Stripe 7";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// --- STRIPE 8 ---
uniform float Stripe8_BaseOff <
    ui_category = "Stripe 8";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.018;

uniform float Stripe8_JetMult <
    ui_category = "Stripe 8";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.018;

uniform float Stripe8_SatMult <
    ui_category = "Stripe 8";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// --- STRIPE 9 ---
uniform float Stripe9_BaseOff <
    ui_category = "Stripe 9";
    ui_type = "slider";
    ui_label = "Base Offset";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.017;

uniform float Stripe9_JetMult <
    ui_category = "Stripe 9";
    ui_type = "slider";
    ui_label = "Burst Multiplier";
    ui_min = -0.1; ui_max = 0.1; ui_step = 0.001;
> = 0.017;

uniform float Stripe9_SatMult <
    ui_category = "Stripe 9";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0; ui_max = 2.0; ui_step = 0.01;
> = 1.0;

// ============================================================================
// ФУНКЦИЯ ХЕШИРОВАНИЯ
// ============================================================================

float hash1(float p) {
    return frac(sin(p * 0.1031) * 43758.5453);
}

// ============================================================================
// ОСНОВНОЙ ПИКСЕЛЬНЫЙ ШЕЙДЕР
// ============================================================================

float4 PS_HeadSwitch(float4 vpos : SV_Position, float2 uv : TEXCOORD0) : SV_Target
{
    float2 res = float2(BUFFER_WIDTH, BUFFER_HEIGHT);
    
    // Изначальный цвет пикселя
    float4 color = tex2D(ReShade::BackBuffer, uv);

    // Определение нижней границы, где начинается эффект
    float glitch_y_start = 1.0 - (StripHeightPercent / 100.0);

    // Если пиксель находится в зоне эффекта
    if (uv.y >= glitch_y_start)
    {
        // === 1. ВРЕМЯ И ГЕНЕРАТОР ШУМА ===
        float T = Time * 24.0 * TimerSpeedMultiplier + float(SEED);
        
        float raw_noise = sin(T * 0.117) + cos(T * 0.383) + sin(T * 0.691) + cos(T * 1.037);
        float norm_noise = (raw_noise + 4.0) / 8.0;
        
        float burst_raw = max(0.0, norm_noise - BurstFrequency) / (1.0 - BurstFrequency);
        float jet = pow(burst_raw, BurstPower);

        // === 2. ГЛОБАЛЬНЫЙ СДВИГ ===
        float rapid_shift = (hash1(T) > 0.5) ? (RapidShift / 100.0) : 0.0;
        
        float base_center = ((BurstMinPercent + BurstMaxPercent) / 2.0) / 100.0;
        float base_amp    = ((BurstMaxPercent - BurstMinPercent) / 2.0) / 100.0;
        float dir = sin(T * 1.37);
        
        float global_off = rapid_shift + ((base_center + base_amp * dir) * jet) + (ExtraShiftPercent / 100.0);

        // === 3. ОПРЕДЕЛЕНИЕ ТЕКУЩЕЙ ПОЛОСЫ ===
        float local_y = (uv.y - glitch_y_start) / (StripHeightPercent / 100.0);
        int stripe_idx = clamp(int(local_y * NUM_STRIPES), 0, NUM_STRIPES - 1);

        // === 4. ПОЛУЧЕНИЕ ПАРАМЕТРОВ КОНКРЕТНОЙ ПОЛОСЫ ===
        float s_base_off, s_jet_mult, s_sat_mult;
        
        switch (stripe_idx) {
            case 0:  s_base_off = Stripe0_BaseOff;  s_jet_mult = Stripe0_JetMult;  s_sat_mult = Stripe0_SatMult;  break;
            case 1:  s_base_off = Stripe1_BaseOff;  s_jet_mult = Stripe1_JetMult;  s_sat_mult = Stripe1_SatMult;  break;
            case 2:  s_base_off = Stripe2_BaseOff;  s_jet_mult = Stripe2_JetMult;  s_sat_mult = Stripe2_SatMult;  break;
            case 3:  s_base_off = Stripe3_BaseOff;  s_jet_mult = Stripe3_JetMult;  s_sat_mult = Stripe3_SatMult;  break;
            case 4:  s_base_off = Stripe4_BaseOff;  s_jet_mult = Stripe4_JetMult;  s_sat_mult = Stripe4_SatMult;  break;
            case 5:  s_base_off = Stripe5_BaseOff;  s_jet_mult = Stripe5_JetMult;  s_sat_mult = Stripe5_SatMult;  break;
            case 6:  s_base_off = Stripe6_BaseOff;  s_jet_mult = Stripe6_JetMult;  s_sat_mult = Stripe6_SatMult;  break;
            case 7:  s_base_off = Stripe7_BaseOff;  s_jet_mult = Stripe7_JetMult;  s_sat_mult = Stripe7_SatMult;  break;
            case 8:  s_base_off = Stripe8_BaseOff;  s_jet_mult = Stripe8_JetMult;  s_sat_mult = Stripe8_SatMult;  break;
            case 9:  s_base_off = Stripe9_BaseOff;  s_jet_mult = Stripe9_JetMult;  s_sat_mult = Stripe9_SatMult;  break;
            default: s_base_off = 0.0; s_jet_mult = 0.0; s_sat_mult = 1.0; break;
        }

        // === 5. РАСЧЁТ ИТОГОВОГО СДВИГА ===
        float final_off_pct = s_base_off + (s_jet_mult * jet) + global_off;
        
        float shift_uv = final_off_pct;
        float2 sample_uv = float2(uv.x - shift_uv, uv.y);

        // === 6. СЭМПЛИНГ С УЧЁТОМ ЧЁРНЫХ ПОЛЕЙ ===
        float4 shifted_color;
        if (sample_uv.x < 0.0 || sample_uv.x > 1.0)
        {
            shifted_color = float4(0.0, 0.0, 0.0, 1.0);
        }
        else
        {
            shifted_color = tex2D(ReShade::BackBuffer, sample_uv);
        }

        // === 7. ВЫБОР РЕЖИМА НАСЫЩЕННОСТИ ===
        float saturation;
        
        if (USE_DYNAMIC_SAT)
        {
            // Динамическая насыщенность
            float sat_base = DynSat_Min + (DynSat_Max - DynSat_Min) * (1.0 - jet * DynSat_BurstInfluence);
            sat_base = clamp(sat_base, DynSat_Min, DynSat_Max);
            
            // Добавление случайной модуляции
            float random_mod = 0.9 + sin(T * 0.2) * DynSat_Fluc;
            saturation = sat_base * s_sat_mult * random_mod;
            
            // Ограничение диапазона
            saturation = clamp(saturation, DynSat_Min, DynSat_Max);
        }
        else
        {
            // Фиксированная насыщенность
            saturation = FIXED_SAT * s_sat_mult;
        }
        
        saturation = clamp(saturation, 0.0, 1.0);

        // === 8. ПРИМЕНЕНИЕ НАСЫЩЕННОСТИ ===
        float luma = dot(shifted_color.rgb, float3(0.299, 0.587, 0.114));
        float3 gray = float3(luma, luma, luma);
        
        float3 final_rgb = lerp(gray, shifted_color.rgb, saturation);

        return float4(final_rgb, shifted_color.a);
    }

    return color;
}

// ============================================================================
// ЗАВЕРШЕНИЕ
// ============================================================================

technique HeadSwitch
{
    pass Pass0
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_HeadSwitch;
    }
}