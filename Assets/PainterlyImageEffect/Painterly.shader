Shader "Unlit/Oil Painting"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Radius ("Radius", Range(0, 10)) = 2
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            
            struct v2f 
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            v2f vert(appdata_base v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            int _Radius;
            float4 _MainTex_TexelSize;
            
            float4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv;
                
                // Média das cores dos nucleos.
                float3 mean[4] = // 4 núcleos
                {
                    {0, 0, 0}, // rgb
                    {0, 0, 0}, 
                    {0, 0, 0},
                    {0, 0, 0}
                };
                
                // Variação das cores dos nucleos.
                float3 variance[4] = // 4 núcleos
                {
                    {0, 0, 0},  // rgb
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0}
                };
                
                float2 start[4] = 
                {
                    {-_Radius, -_Radius}, 
                    {-_Radius, 0}, 
                    {0, -_Radius}, 
                    {0, 0}
                };
                
                float2 pos;
                float3 col;

                for (int k = 0; k < 4; k++) // Núcleos
                {
                    for(int i = 0; i <= _Radius; i++) 
                    {
                        for(int j = 0; j <= _Radius; j++) 
                        {
                            pos = float2(i, j) + start[k];
                            // _MainTex_TexelSize = 1.0f / tamanho da textura.
                            float2 texelOffset = float2(pos.x * _MainTex_TexelSize.x, pos.y * _MainTex_TexelSize.y);
                            col = tex2Dlod(_MainTex, float4(uv + texelOffset, 0., 0.)).rgb;
                            mean[k] += col;
                            variance[k] += col * col;
                        }
                    }
                }
                
                float auxVariance;
                
                float n = pow(_Radius + 1, 2);
                float4 color = tex2D(_MainTex, uv);
                float min = 1;
                
                for (int k = 0; k < 4; k++) // Núcleos
                {
                    // Calcula a média dividindo pelo total de amostras.
                    mean[k] /= n;
                    variance[k] = abs(variance[k] / n - mean[k] * mean[k]);
                    auxVariance = variance[k].r + variance[k].g + variance[k].b;
                    
                    if (auxVariance < min) // Encontra o que tem menor variação.
                    {
                        min = auxVariance;
                        color.rgb = mean[k].rgb; // Recebe a média da cor do núcleo.
                    }
                }

                return color;
            }
            ENDCG
        }
    }
}