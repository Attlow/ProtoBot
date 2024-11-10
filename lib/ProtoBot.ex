defmodule ProtoBot do
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    unless msg.author.bot do
    cond do
      String.starts_with?(String.downcase(msg.content), "!guess") ->
        handle_name(msg)

      String.starts_with?(String.downcase(msg.content), "!randomquote") ->
        handle_quote(msg)

      String.starts_with?(String.downcase(msg.content), "!roll") ->
        handle_roll(msg)

      String.starts_with?(String.downcase(msg.content), "!ygo") ->
        handle_ygo(msg)

      String.starts_with?(String.downcase(msg.content), "!dog") ->
        handle_dog(msg)

      String.starts_with?(String.downcase(msg.content), "!horrormovie") ->
        handle_movie(msg)

      String.starts_with?(String.downcase(msg.content), "!command") ->
        Api.create_message(msg.channel_id, """
                !Guess
                !RandomQuote
                !Roll
                !Ygo
                !Dog
                """)

      true ->
        :ignore
    end
  end
end

  defp handle_name(msg) do
    case String.split(msg.content, " ", parts: 2, trim: true) do
      [_, name] -> get_name_result(msg, name)
      _ -> Api.create_message(msg.channel_id, "Digite !guess [primeiro ou último nome]")
    end
  end

  defp handle_roll(msg) do
    case String.split(msg.content, " ", parts: 2, trim: true) do
      [_, dice] -> get_dice_result(msg, dice)
      _ -> Api.create_message(msg.channel_id, "Insira o(s) dados que quer rolar. Ex: [!roll 2d20]")
    end
  end

  defp handle_quote(msg) do
    get_quote_result(msg)
  end

  defp handle_ygo(msg) do
    case String.split(msg.content, " ", parts: 2, trim: true) do
      [_, card] -> get_card_result(msg, card)
      _ -> Api.create_message(msg.channel_id, "Digite o nome de uma carta de Yu-Gi-Oh!")
    end
  end

  defp handle_dog(msg) do
    get_dog_result(msg)
  end

  defp handle_movie(msg) do
    case String.split(msg.content, " ", parts: 2, trim: true) do
      [_, name] -> get_movie_result(msg, name)
      _ -> Api.create_message(msg.channel_id, "Insira uma id válida!")
    end
  end

  defp get_name_result(msg, name) do
    n = URI.encode(name)

    url = "https://api.nationalize.io/?name=#{n}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        read = Jason.decode!(body)

        case List.first(read["country"]) do
          %{"country_id" => pais, "probability" => chance} ->
            Api.create_message(msg.channel_id, "#{name} é de #{ISO.country_name(pais)} com #{(Float.round((chance * 100), 2))}% de certeza!")

          nil ->
            Api.create_message(msg.channel_id, "Não foi possível determinar o país para #{name}.")
        end
      end
    end



  defp get_quote_result(msg) do
    url = "https://animechan.io/api/v1/quotes/random"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        read = Jason.decode!(body)

        case read["data"] do
          %{
            "anime" => %{"name" => anime_name},
            "character" => %{"name" => character_name},
            "content" => frase
          } ->
              Api.create_message(msg.channel_id, "Frase: #{frase}\nAnime: #{anime_name}\nPersonagem: #{character_name}")

            _ ->
              Api.create_message(msg.channel_id, "Erro ao processar a citação.")
          end
      end
    end

    defp get_dice_result(msg, dice) do
      n = URI.encode(dice)

      url = "https://rpg-dice-roller-api.djpeacher.com/api/roll/#{n}"

      case HTTPoison.get(url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          read = Jason.decode!(body)
          dice = read["output"]

          Api.create_message(msg.channel_id, dice)

        _ ->
          Api.create_message(msg.channel_id, "Formato inválido")
          end
        end

      defp get_card_result(msg, card) do
        n = URI.encode(card)

        url = "https://db.ygoprodeck.com/api/v7/cardinfo.php?name=#{n}"

        case HTTPoison.get(url) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            read = Jason.decode!(body)

            case read["data"] do
              [%{
                "name" => cardName,
                "humanReadableCardType" => cardType,
                "race" => cardRace,
                "attribute" => cardAtribute,
                "archetype" => cardArchetype,
                "card_images" => cardImages,
                "card_prices" => cardPrices
              }] ->
                firstImage = List.first(cardImages)
                imageUrl = firstImage["image_url"]

                firstPrice = List.first(cardPrices)
                marketPrice = firstPrice["cardmarket_price"]

                Api.create_message(msg.channel_id, """
                Carta: #{cardName}
                Tipo: #{cardType}
                Raça: #{cardRace}
                Atributo: #{cardAtribute}
                Arquétipo: #{cardArchetype}
                Preço: US$ #{marketPrice}
                Imagem: #{imageUrl}
                """)

              end
            end
          end


    defp get_dog_result(msg) do
        url = "https://dog.ceo/api/breeds/image/random"
        case HTTPoison.get(url) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            read = Jason.decode!(body)
            foto = read["message"]
        Api.create_message(msg.channel_id, foto)
      end
    end

    defp get_movie_result(msg, name) do
      n = URI.encode(name)

      url = "http://127.0.0.1:5000/movies/#{n}"

      case HTTPoison.get(url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          read = Jason.decode!(body)

          case read do
            [%{
              "name" => movieName,
              "scarescore" => scarescore,
              "score" => score,
              "sustoscore" => sustoscore,
              "img" => img,
            }] ->

              Api.create_message(msg.channel_id, """
              Nome: #{movieName}
              Score: #{score}
              ScareScore: #{scarescore}
              SustoScore: #{sustoscore}
              Img: #{img}
              """)

            end
          end
        end
end
