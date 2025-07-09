# ☕ Máquina de Café em Assembly (MIPS)

Este é um projeto para a disciplina de **Organização e Arquitetura de Computadores I** do curso de Engenharia de Computação. O código, desenvolvido em Assembly para a arquitetura MIPS, simula o funcionamento de uma máquina de café interativa, executada através do simulador MARS.

## ⚙️ Funcionalidades

O projeto implementa uma máquina de café completa com as seguintes características:

* **Menu Interativo:** Um menu principal guia o usuário na escolha das bebidas ou na entrada do modo de manutenção.
* **Variedade de Bebidas:** O usuário pode escolher entre três opções de bebidas:
    1.  Café Puro
    2.  Café com Leite
    3.  Mochaccino
* **Customização do Pedido:** É possível personalizar cada bebida escolhendo:
    * **Tamanho:** Pequeno (`p`) ou Grande (`g`).
    * **Açúcar:** Adicionar (`s`) ou não (`n`).
* **Controle de Estoque:** A máquina gerencia dinamicamente o estoque de ingredientes (café, leite, chocolate, açúcar).
    * Cada bebida consome uma ou duas doses de cada ingrediente, dependendo do tamanho escolhido.
    * O sistema verifica a disponibilidade de ingredientes antes de preparar a bebida.
    * Se um ingrediente for insuficiente, a máquina exibe uma mensagem de erro e impede a venda.
* **Modo de Manutenção:** Uma opção no menu principal permite reabastecer o estoque de cada ingrediente individualmente, restaurando-os para a capacidade máxima de 20 unidades.
* **Cálculo de Preços:** Os preços são calculados dinamicamente com base na bebida e no tamanho selecionado.
    * Preços base: Café (R$ 2,00), Café com Leite (R$ 3,00), Mochaccino (R$ 4,00).
    * Adicional para tamanho grande: + R$ 1,50.
* **Geração de Cupom Fiscal:** Após cada compra bem-sucedida, um cupom fiscal em formato `.txt` é gerado.
    * O arquivo é nomeado sequencialmente (ex: `cupom_1.txt`, `cupom_2.txt`, etc.).
    * O cupom contém os detalhes do pedido: nome da bebida, tamanho, se foi adicionado açúcar e o preço final.
    * O sistema localiza automaticamente o próximo número de cupom vago ao ser inicializado.
* **Simulação de Preparo:** Um "timer" é acionado durante o preparo da bebida, simulando o tempo de espera real, que varia conforme a complexidade e o tamanho do pedido.

## 🛠️ Como Executar

Para rodar este projeto, você precisará do simulador **MARS (MIPS Assembler and Runtime Simulator)**.

1.  **Baixe o MARS:** Faça o download do simulador, caso ainda não o tenha.
2.  **Obtenha o código:** Salve o código fornecido em um arquivo com a extensão `.asm` (ex: `maquina_cafe.asm`).
3.  **Abra o Arquivo no MARS:**
    * Inicie o simulador MARS.
    * Vá em `File > Open...` e selecione o arquivo `maquina_cafe.asm`.
4.  **Monte o Código:**
    * Clique em `Run > Assemble` (ou pressione a tecla `F3`).
5.  **Execute o Programa:**
    * Clique em `Run > Go` (ou pressione a tecla `F5`).
6.  **Interaja com a Máquina:** O console de I/O do MARS (na parte inferior da tela) exibirá o menu da máquina de café. Siga as instruções para fazer seu pedido.

> **Nota:** Os arquivos de cupom (`.txt`) serão salvos no mesmo diretório onde o simulador MARS foi iniciado.

## 📄 Estrutura do Código

O código é organizado em seções e procedimentos para facilitar a leitura e manutenção:

* **`.data`**: Contém a declaração de todas as variáveis, estoques, preços e mensagens de texto utilizadas no programa.
* **`.text`**: Contém toda a lógica executável do programa.
    * `main`: Rotina principal que controla o fluxo do programa e o menu.
    * **Procedimentos de Preparo:** `verificar_estoque`, `reduzir_estoque`, `timer_bebida`.
    * **Procedimentos de Cupom:** `gerar_cupom`, `calcular_preco`, `formatar_preco`.
    * **Procedimentos de Manutenção:** `reabastecer_estoque`, `inicializar_estoques`.
    * **Procedimentos Auxiliares:** Funções para manipulação de strings (`strlen`, `strcat`), conversão de tipos (`int_to_ascii`) e inicialização do contador de cupons (`inicializar_contador`).

## ✒️ Autores

* **Diogo Borges Corso**
* **João Vitor Wagner Pereira**