using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class PainterlyImageEffect : MonoBehaviour
{
	[Range(0, 10)]
	public float intensity;
	private Material material;

	private void Awake()
	{
		// Cria um material com o shader do filtro.
		material = new Material(Shader.Find("Unlit/Oil Painting"));
	}

	// Chamado depois que toda a renderização é concluída para renderizar a imagem.
	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (intensity <= 0)
		{
			// Copia a texture original para a textura de destino sem aplicar o efeito.
			Graphics.Blit(source, destination);
			return;
		}

		// Altera o tamanho da matriz do núcleo.
		material.SetFloat("_Radius", intensity);

		// Copia a texture original, aplica o filtro e passa para a textura de destino.
		// Como só existe um efeito de postprocessing, já será renderizado para a câmera.
		Graphics.Blit(source, destination, material);
	}
}