module Translator

    class App < Sinatra::Base

        before do
            env["warden"].authenticate!(scope: "admin")
        end
        
        set :environment, Rails.env
        enable :inline_templates

        get "/:from/:to" do |from, to|
            exhibit_translations(from, to)
        end

        post "/:from/:to" do |from, to|
            I18n.backend.store_translations to, decoded_translations, escape: false
            Translator.store.save
            @message = "Translations stored with success!"
            exhibit_translations(from, to)
        end

    protected

        # Store from and to locales in variables and retrieve
        # all keys available for translation.
        def exhibit_translations(from, to)
            @from, @to, @keys = from, to, available_keys(from)
            haml :index
        end

        def decoded_translations
            translations = params.except("from", "to")
            translations.each do |key, value|
                translations[key] = ActiveSupport::JSON.decode(value) rescue nil
            end
        end

        # Get all keys for a locale. Remove the locale from the key and sort them.
        # If a key is named "en.foo.bar", this method will return it as "foo.bar".
        def available_keys(locale)
            keys = Translator.store.keys("#{locale}.*")
            range = Range.new(locale.size + 1, -1)
            keys.map { |k| k.slice(range) }.sort!
        end

        # Get the value in the translator store for a given locale. This method
        # decodes values and checks if they are a hash, as we don't want subtrees
        # available for translation since they are managed automatically by I18n.
        def locale_value(locale, key)
            value = Translator.store["#{locale}.#{key}"]
            value if value && !ActiveSupport::JSON.decode(value).is_a?(Hash)
        end
    end
end
__END__
@@ index
!!!
%html
%head
    %title
        Translator::App
%body
    %h2= "From #{@from} to #{@to}"

    %p(style="color:green")= @message

    - if @keys.empty?
    No translations available for #{@from}
    - else
        %form(method="post" action="")
            - @keys.each do |key|
                - from_value = locale_value(@from, key)
                - next unless from_value
                - to_value = locale_value(@to, key) || from_value
                %p
                    %label(for=key)
                        %small= key
                        = from_value
                    %br
                    %input(id=key name=key type="text" value=to_value size="120")
            %p
                %input(type="submit" value="Store translations")