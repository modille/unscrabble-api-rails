class ApplicationController < ActionController::API

  def unscrabble
    if params[:rack].present?
      results = solve( params[:rack], params[:regex] )
      render json: { results: results }
    else
      render json: { error: I18n.t('error.rack_required') }, status: :unprocessible_entity
    end
  end

  private

  def solve( rack, regex )
    matches = []

    IO.foreach UnscrabbleApi::Application.config.dictionary_path do |word|
      word = word.chomp.downcase
      rack = rack.chomp.downcase
      temp_rack = rack

      begin
        word.chars.each do |letter|
          if temp_rack =~ /#{letter}/
            temp_rack = temp_rack.sub( letter, '' )
          elsif temp_rack =~ /\*/
            temp_rack = temp_rack.sub( '*', '' )
          else
            raise 'Not a match'
          end
        end

        if regex
          matches << word if word =~ /#{regex}/
        else
          matches << word
        end
      rescue
      end
    end

    matches
  end

end