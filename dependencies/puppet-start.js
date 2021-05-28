const puppeteer = require('puppeteer');
//const puppeteer = require('puppeteer-core');
let chromeOptions = [  
  '--debug',      
  '--enable-logging=stderr',
  '--v=1',
  '--disable-dev-shm-usage',
  '--remote-debugging-address=0.0.0.0',
  '--remote-debugging-port=9222',
  '--start-in-incognito',
  '--disable-gpu',
  '--user-data-dir=/home/chromium/downloads',
  '--allow-insecure-localhost',
  '--single-process'  
  //'--no-sandbox',
  //'--allow-insecure-localhost',  
  //'--disable-composited-antialiasing',
  //'--disable-crash-reporter', 
  //'--disable-low-res-tiling', 
  //'--profiler-timing=0',  
  //'--no-zygote',
  //'--no-sandbox',  
  //'--no-gpu',
  //'--disable-dev-shm-usage',
  //'--no-default-browser-check', 
  //'--disable-setuid-sandbox',
  //'--no-first-run',
  //'--use-fake-ui-for-media-stream',
  //'--use-fake-device-for-media-stream'  
];

(async () => {
    //debugger;
    const browser = await puppeteer.launch({
      defaultViewport: {width: 1920, height: 1080},
      args: chromeOptions,
      executablePath: "/usr/bin/chromium"
    });

    const page = await browser.newPage();

    await page.goto('https://webscraper.io/test-sites/e-commerce/allinone');
    const url = await page.url();
    console.log(url);  
    const title = await page.title();
    console.log(title);    
    await page.screenshot({ path: 'screenshot.png' });
    const result = await page.evaluate(() => {
      return document.querySelectorAll('body')
    })        
    console.log(result);
    browser.close();
})();