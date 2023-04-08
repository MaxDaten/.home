{
  # https://kadekillary.work/posts/1000x-eng/
  hey_gpt = {
    argumentNames = ["prompt"];
    body = ''
      set gpt (curl https://api.openai.com/v1/chat/completions -s \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d '{
          "model": "gpt-3.5-turbo",
          "messages": [{"role": "user", "content": "'$prompt'"}],
          "temperature": 0.7,
          "stream": true
      }')
      for text in $gpt
        if test $text = 'data: [DONE]'
          break
        else if string match -q --regex "role" $text
          continue
        else if string match -q --regex "content" $text
          echo -n $text | string replace 'data: ' "" | jq -r -j '.choices[0].delta.content'
        else
          continue
        end
      end
    '';
  };

  data_gpt = {
    argumentNames = ["prompt" "data"];
    body = ''
      set prompt_input (echo "$prompt:\n$data" | string join ' ')
      hey_gpt (echo "$prompt_input" | jq -sRr @json | string trim -c '"')
    '';
  };
}
