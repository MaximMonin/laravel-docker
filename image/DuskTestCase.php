<?php

namespace Tests;

use Facebook\WebDriver\Chrome\ChromeOptions;
use Facebook\WebDriver\Remote\DesiredCapabilities;
use Facebook\WebDriver\Remote\RemoteWebDriver;
use Laravel\Dusk\TestCase as BaseTestCase;

abstract class DuskTestCase extends BaseTestCase
{
    use CreatesApplication;

    /**
     * Prepare for Dusk test execution.
     *
     * @beforeClass
     * @return void
     */
    public static function prepare()
    {
        if (env('USE_SELENIUM', 'false') !== 'true') {
          static::startChromeDriver();
        }
    }

    /**
     * Create the RemoteWebDriver instance.
     *
     * @return \Facebook\WebDriver\Remote\RemoteWebDriver
     */
    protected function driver()
    {
        $options = (new ChromeOptions)->addArguments([
          '--disable-gpu',
          '--headless',
          '--window-size=1920,1080',
          '--no-sandbox',
          '--ignore-ssl-errors',
          '--whitelisted-ips=""',
        ]);

        if (env('USE_SELENIUM', 'false') == 'true') {
           return RemoteWebDriver::create(
              env('SELENIUM_HUB', 'http://selenium:4444/wd/hub'), DesiredCapabilities::chrome()->setCapability(
              ChromeOptions::CAPABILITY, $options
           ));
        } else {
           return RemoteWebDriver::create(
             'http://localhost:9515', DesiredCapabilities::chrome()->setCapability(
                 ChromeOptions::CAPABILITY, $options
            ));
        }
    }
}
