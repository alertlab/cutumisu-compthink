# frozen_string_literal: true

module Selenium
   # Unofficial extension to attempt to patch Selenium Manager's missing behaviour of downloading chrome-headless-shell
   # https://github.com/SeleniumHQ/selenium/issues/16276
   module ManagerHeadlessExtension
      CHROME_ENDPOINT_HOST = 'https://googlechromelabs.github.io'

      # Chrome download index JSON endpoint.
      # @see https://github.com/GoogleChromeLabs/chrome-for-testing#json-api-endpoints
      CHROME_ENDPOINT_PATH = '/chrome-for-testing/known-good-versions-with-downloads.json'

      # This is duplicating the autodownload behaviour of SeleniumManager, which fetches the Chrome for Testing binary, but
      # neglects the chrome-headless-shell (CHS) binary.
      # CHS used to be bundled as part of the main chrome binary, accessible with --headless=old, but as of Chrome 131,
      # that option is no longer available. (https://developer.chrome.com/blog/removing-headless-old-from-chrome)
      #
      # As a side note, when attempting to use --headless=old, ChromeDriver provides the useless generic error:
      #
      #    session not created: probably user data directory is already in use, please specify a unique value for --user-data-dir argument, or don't use --user-data-dir
      #
      # This tidbit is not Selenium's fault per se, but is included for searchability.
      #
      # It would be grand if the decision in https://github.com/SeleniumHQ/selenium/issues/13600 could be reversed now that
      # the context has changed. Selenium Manager should be fetching both binaries (chrome and chrome-headless-shell) on
      # its own.
      #
      # @note This may not account for pinned version nor multiple platforms. Alter to your needs.
      def self.chrome_headless_binary
         chrome_version = ENV.fetch('TEST_CHROME_VERSION', '')

         args = []
         args << '--browser=chrome'
         args << "--browser-version=#{ chrome_version }" unless chrome_version.empty?

         main_chrome_bin = ::Selenium::WebDriver::SeleniumManager.binary_paths(*args)['browser_path']

         headless_chrome_bin = main_chrome_bin.gsub('chrome', 'chrome-headless-shell')

         unless File.exist? headless_chrome_bin
            version = Gem::Version.create(`#{ main_chrome_bin } --version`.strip.split.last)

            warn "WARNING: chrome-headless-shell #{ version } not installed by Selenium. Will attempt download to fix."

            fetch_headless version, install_dir: File.dirname(headless_chrome_bin)
         end

         headless_chrome_bin
      end

      def self.fetch_headless(version, install_dir:)
         endpoint = fetch_download_endpoint version

         tmp_dir  = Dir.mktmpdir 'selenium_download_'
         zip_path = "#{ tmp_dir }/#{ endpoint.basename }"

         download endpoint, to: zip_path

         unzip zip_path, install_dir

         File.delete zip_path
         Dir.rmdir tmp_dir
      end

      def self.download(source, to:)
         target_path = to

         warn "Downloading #{ source } to #{ target_path }"
         Net::HTTP.get_response(source) do |response|
            File.open target_path, 'wb' do |io|
               response.read_body do |chunk|
                  io.write chunk
               end
            end
         end
      end

      def self.fetch_download_endpoint(version)
         version_metadata = fetch_versions.find do |meta|
            version == meta[:version]
         end

         endpoint = version_metadata[:downloads][:'chrome-headless-shell'].find do |download_target|
            download_target[:platform] == chrome_platform
         end

         Addressable::URI.parse endpoint[:url]
      end

      def self.fetch_versions
         listing_endpoint = Addressable::URI.parse(CHROME_ENDPOINT_HOST).join(CHROME_ENDPOINT_PATH)

         warn "Fetching version listing from #{ listing_endpoint }"
         response = Net::HTTP.get_response listing_endpoint

         JSON.parse(response.body, symbolize_names: true)[:versions]
      end

      def self.unzip(zip_path, target_dir)
         warn "Unzipping to #{ target_dir }"

         FileUtils.mkdir_p target_dir
         `unzip -o #{ zip_path } -d #{ target_dir }`

         # clean up nested dir, since unzip cannot ignore a dir level
         nested_dir = "#{ target_dir }/chrome-headless-shell-#{ chrome_platform }"
         FileUtils.mv Dir.glob("#{ nested_dir }/*"), target_dir

         Dir.rmdir nested_dir
      end

      def self.chrome_platform
         case ::Selenium::WebDriver::Platform.os
         when :linux
            'linux64'
         when :windows
            'win64'
         else
            raise 'incomplete list of platforms. Add yours as needed'
         end
      end
   end
end
