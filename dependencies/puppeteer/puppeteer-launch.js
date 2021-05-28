const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    defaultViewport: {width: 1920, height: 1080},
    executablePath: "/usr/bin/chromium"
  });
  const page = await browser.newPage();

  await page.goto('https://pptr.dev');

  // Waits until the `title` meta element is rendered
  await page.waitForSelector('title');
  
  const title = await page.title();
  console.info(`The title is: ${title}`);

  await browser.close();
})();