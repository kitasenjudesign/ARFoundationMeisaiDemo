Shader "MEISAI"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _StencilTex ("_StencilTex", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "./noise/SimplexNoise3D.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _StencilTex;
            
            float2 GetStencilUV( float2 uv ){

                float2 stencilUV = float2(
                    1-uv.y,
                    1-uv.x
                );

                float camTexWidth = 1920;
                float camTexHeight = 1440;
                float aspect = (camTexWidth/camTexHeight) / (_ScreenParams.y/_ScreenParams.x);

                stencilUV.y = stencilUV.y * aspect + (1-aspect)/2;

                return stencilUV;

            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 camCol = tex2D(_MainTex, i.uv);

                float2 displacedUV = float2(
                    0.5 * snoise(float3(i.uv.x+camCol.r*2.0,i.uv.y+camCol.g*2.0, _Time.y*0.3)),
                    0.5 * snoise(float3(i.uv.x+camCol.g*2.0,i.uv.y+camCol.b*2.0, _Time.y*0.4))
                );
                displacedUV = frac( i.uv + displacedUV );

                fixed4 displacedCol = tex2D(_MainTex, displacedUV);

                fixed4 stencil = tex2D(_StencilTex, GetStencilUV(i.uv));

                return lerp( camCol, displacedCol, stencil.r);

            }
            ENDCG
        }
    }
}
