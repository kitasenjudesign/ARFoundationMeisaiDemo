using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class PostEffect : MonoBehaviour
{
    
    [SerializeField] private Shader _shader;
    [SerializeField] private AROcclusionManager occlusionManager;
    private Material _material;

    void Awake()
    {
        _material = new Material(_shader);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(occlusionManager!=null){
            _material.SetTexture("_StencilTex",occlusionManager.humanStencilTexture);     
        }
        Graphics.Blit(source, destination, _material);
    }

}