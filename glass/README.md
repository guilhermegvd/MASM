# Glass

- Este programa construído em Assembly x86 abre uma janela transparente com efeito Aero Glass no Windows Vista / 7.

![Efeito vidro do Aero Glass na janela inteira](https://guilhermevieiradutra.com.br/github/b546fdhr84.png)

### Processo
- Para atingir este resultado devemos definir a cor de fundo da janela para preto (hbrBackground = 0X0h) e chamamos a função **DwmExtendFrameIntoClientArea** (dwmapi.lib) após **UpdateWindow**, passando -1 para todos os valores de margem.

### Importante
- Para construir e executar este programa utilize o build.bat localizado na raíz deste repositório:

```shell
build.bat glass
```