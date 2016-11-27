# How To
- While in development mode, add missing emails keys to `./en.json`
- Once deployed, Transifex will update its strings list for all languages from [`en.json`](https://inventaire.io/public/i18n/src/emails/en.transifex.json)
- All contributions should then happen on the [Transifex project](http://transifex.com/inventaire/inventaire/)
- Contributions are then pulled from Transifex to generate the i18n files for each languages

# Details
- keys let empty in `en.json` are those expected to be taken from the client i18n dist files
