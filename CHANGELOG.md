# Changelog

## [2.0.0](https://github.com/henry-hsieh/personal-setup/compare/v1.10.0...v2.0.0) (2025-12-13)


### ⚠ BREAKING CHANGES

* **nvim:** replace ltex-ls with harper-ls ([#341](https://github.com/henry-hsieh/personal-setup/issues/341))
* migrate to Ubuntu 18.04 ([#326](https://github.com/henry-hsieh/personal-setup/issues/326))
* **zoxide:** use zoxide to replace bd and goto ([#316](https://github.com/henry-hsieh/personal-setup/issues/316))
* **nvim:** retire neoconf.nvim ([#314](https://github.com/henry-hsieh/personal-setup/issues/314))
* **nvim:** replace many plugins with snacks.nvim ([#307](https://github.com/henry-hsieh/personal-setup/issues/307))
* **nvim:** migrate from nvim-cmp to blink.cmp ([#303](https://github.com/henry-hsieh/personal-setup/issues/303))
* **nvim:** upgrade nvim-treesitter to new main branch ([#300](https://github.com/henry-hsieh/personal-setup/issues/300))
* **nvim:** migrate from feline.nvim to lualine.nvim ([#296](https://github.com/henry-hsieh/personal-setup/issues/296))
* **nvim:** update nvim-lspconfig to Nvim 0.11+ settings ([#290](https://github.com/henry-hsieh/personal-setup/issues/290))
* **nvim:** migrate from nvim-base16 to tinted-nvim ([#289](https://github.com/henry-hsieh/personal-setup/issues/289))
* **nvim:** migrate from hop.nvim to flash.nvim ([#286](https://github.com/henry-hsieh/personal-setup/issues/286))

### Features

* **agents:** update git pr guidelines and commit command with enhanced template ([#402](https://github.com/henry-hsieh/personal-setup/issues/402)) ([0cb4ae6](https://github.com/henry-hsieh/personal-setup/commit/0cb4ae601142bf628ceb04e7e510c833a5f3cb72))
* **ai:** add opencode as code agent ([#382](https://github.com/henry-hsieh/personal-setup/issues/382)) ([7aef7cc](https://github.com/henry-hsieh/personal-setup/commit/7aef7ccf77ffb13b73ae878456692102530739d2))
* **ai:** add sidekick.nvim, crush, copilot-lsp and copilot-cli ([b387287](https://github.com/henry-hsieh/personal-setup/commit/b387287f4b0331cacca3ed39d754737317bf1fe6))
* **bat:** bump bat version to v0.26.0 ([#346](https://github.com/henry-hsieh/personal-setup/issues/346)) ([e990e75](https://github.com/henry-hsieh/personal-setup/commit/e990e754c6a9b952e7611165311df3a1808736fa))
* **bat:** bump bat version to v0.26.1 ([#439](https://github.com/henry-hsieh/personal-setup/issues/439)) ([2f20abe](https://github.com/henry-hsieh/personal-setup/commit/2f20abe0de79c9a4603c15e1b2008ddba56a223d))
* **crush:** bump crush version to v0.18.1 ([#373](https://github.com/henry-hsieh/personal-setup/issues/373)) ([ee08c8a](https://github.com/henry-hsieh/personal-setup/commit/ee08c8a6bb6c1e277e80b48590fc156f7be19e22))
* **crush:** bump crush version to v0.18.2 ([#377](https://github.com/henry-hsieh/personal-setup/issues/377)) ([26a3f00](https://github.com/henry-hsieh/personal-setup/commit/26a3f00b6e83918e819493386011a2812ca079f0))
* **crush:** bump crush version to v0.18.3 ([#379](https://github.com/henry-hsieh/personal-setup/issues/379)) ([4de1739](https://github.com/henry-hsieh/personal-setup/commit/4de173947448f5e6539c053a408b2bb697cc091d))
* **crush:** bump crush version to v0.18.4 ([#381](https://github.com/henry-hsieh/personal-setup/issues/381)) ([cf7c268](https://github.com/henry-hsieh/personal-setup/commit/cf7c2689bddb98a1fcb7c64fc71d1849f3d5f432))
* **crush:** bump crush version to v0.18.5 ([#391](https://github.com/henry-hsieh/personal-setup/issues/391)) ([7e17329](https://github.com/henry-hsieh/personal-setup/commit/7e173296fce6fb3e262d7d6c58bf40a2c0226f98))
* **crush:** bump crush version to v0.18.6 ([#411](https://github.com/henry-hsieh/personal-setup/issues/411)) ([1ead235](https://github.com/henry-hsieh/personal-setup/commit/1ead235d69dcc3a84ec90fe8b080a04b609b4f0e))
* **crush:** bump crush version to v0.19.1 ([#420](https://github.com/henry-hsieh/personal-setup/issues/420)) ([46c9753](https://github.com/henry-hsieh/personal-setup/commit/46c97536c0c0c3a91ca05f0b8f219b7140661104))
* **crush:** bump crush version to v0.19.2 ([#421](https://github.com/henry-hsieh/personal-setup/issues/421)) ([2d7e478](https://github.com/henry-hsieh/personal-setup/commit/2d7e4780c268406cb0bd0edb12216b1555edb4d5))
* **crush:** bump crush version to v0.19.3 ([#428](https://github.com/henry-hsieh/personal-setup/issues/428)) ([9963cc2](https://github.com/henry-hsieh/personal-setup/commit/9963cc2127308dca205a27f5b81c05d1b84351c0))
* **crush:** bump crush version to v0.19.4 ([#433](https://github.com/henry-hsieh/personal-setup/issues/433)) ([bbf132f](https://github.com/henry-hsieh/personal-setup/commit/bbf132f7ddf82dca6d9f07304114d368017ae53d))
* **crush:** bump crush version to v0.20.1 ([#437](https://github.com/henry-hsieh/personal-setup/issues/437)) ([2f9b685](https://github.com/henry-hsieh/personal-setup/commit/2f9b685b53c22ae8da928e8f966ac7939587ca09))
* **crush:** bump crush version to v0.22.1 ([#440](https://github.com/henry-hsieh/personal-setup/issues/440)) ([b7d05c5](https://github.com/henry-hsieh/personal-setup/commit/b7d05c5f68e6abad9fd34fcd46bd219cd05f06df))
* **crush:** bump crush version to v0.22.2 ([#447](https://github.com/henry-hsieh/personal-setup/issues/447)) ([8e53e5c](https://github.com/henry-hsieh/personal-setup/commit/8e53e5cd674400979fb5c1fcd719acba15663694))
* **crush:** bump crush version to v0.23.0 ([#452](https://github.com/henry-hsieh/personal-setup/issues/452)) ([f8afe63](https://github.com/henry-hsieh/personal-setup/commit/f8afe632739d12faf8384fe63ef48f97eed41213))
* **crush:** bump crush version to v0.24.0 ([#453](https://github.com/henry-hsieh/personal-setup/issues/453)) ([797c364](https://github.com/henry-hsieh/personal-setup/commit/797c364909225f2e3dc4cde18ae42ad6262780c4))
* **fd:** bump fd version to v10.3.0 ([#319](https://github.com/henry-hsieh/personal-setup/issues/319)) ([4d05497](https://github.com/henry-hsieh/personal-setup/commit/4d05497e48be44c19e0af77fc4673d5d860f101e))
* **fzf:** bump fzf version to v0.60.3 ([#239](https://github.com/henry-hsieh/personal-setup/issues/239)) ([8a18d97](https://github.com/henry-hsieh/personal-setup/commit/8a18d979cf3b4ba1feefdc1f8f5ce51fb0303259))
* **fzf:** bump fzf version to v0.61.0 ([#245](https://github.com/henry-hsieh/personal-setup/issues/245)) ([f29e206](https://github.com/henry-hsieh/personal-setup/commit/f29e206bacc0a174475fd90c99ddbec2dfe1088c))
* **fzf:** bump fzf version to v0.61.1 ([#246](https://github.com/henry-hsieh/personal-setup/issues/246)) ([3b8dbe8](https://github.com/henry-hsieh/personal-setup/commit/3b8dbe86706e9bd64fc6f9bc89b319a9abed19e6))
* **fzf:** bump fzf version to v0.61.2 ([#250](https://github.com/henry-hsieh/personal-setup/issues/250)) ([7406a7c](https://github.com/henry-hsieh/personal-setup/commit/7406a7cb4feef74448b16272940a3b16a21bfad8))
* **fzf:** bump fzf version to v0.61.3 ([#251](https://github.com/henry-hsieh/personal-setup/issues/251)) ([2eeae49](https://github.com/henry-hsieh/personal-setup/commit/2eeae4949521e7c02429d1cefc7bec9c6479b043))
* **fzf:** bump fzf version to v0.62.0 ([#255](https://github.com/henry-hsieh/personal-setup/issues/255)) ([c8e878e](https://github.com/henry-hsieh/personal-setup/commit/c8e878ef852529bccd8620ac673d6977598b7960))
* **fzf:** bump fzf version to v0.63.0 ([#270](https://github.com/henry-hsieh/personal-setup/issues/270)) ([713cc9e](https://github.com/henry-hsieh/personal-setup/commit/713cc9ebcb4137735e5071aa32c32e2980b1151d))
* **fzf:** bump fzf version to v0.64.0 ([#272](https://github.com/henry-hsieh/personal-setup/issues/272)) ([9b22ce8](https://github.com/henry-hsieh/personal-setup/commit/9b22ce8da488b89195d8f112aaef5dde075d88dc))
* **fzf:** bump fzf version to v0.65.0 ([#285](https://github.com/henry-hsieh/personal-setup/issues/285)) ([bde9a21](https://github.com/henry-hsieh/personal-setup/commit/bde9a21bd8737e2614e2be5e9ed65b15b03d223d))
* **fzf:** bump fzf version to v0.65.1 ([#292](https://github.com/henry-hsieh/personal-setup/issues/292)) ([7b3811f](https://github.com/henry-hsieh/personal-setup/commit/7b3811f3c04d451246591bc013d25bef1c17cd0d))
* **fzf:** bump fzf version to v0.65.2 ([#328](https://github.com/henry-hsieh/personal-setup/issues/328)) ([6204f48](https://github.com/henry-hsieh/personal-setup/commit/6204f4817eb3af32248ec52bcbd35adbc929cf94))
* **fzf:** bump fzf version to v0.66.0 ([#343](https://github.com/henry-hsieh/personal-setup/issues/343)) ([2c7d7aa](https://github.com/henry-hsieh/personal-setup/commit/2c7d7aa95c2b79e2e31bb1d2f4f35244973bf8fc))
* **fzf:** bump fzf version to v0.66.1 ([#357](https://github.com/henry-hsieh/personal-setup/issues/357)) ([fbb81b8](https://github.com/henry-hsieh/personal-setup/commit/fbb81b825f25c9be82d974d270eafaa4693c513f))
* **fzf:** bump fzf version to v0.67.0 ([#374](https://github.com/henry-hsieh/personal-setup/issues/374)) ([6c64b61](https://github.com/henry-hsieh/personal-setup/commit/6c64b61819f64dcafd281be99400573d8f8fb8c3))
* **gh:** add Github CLI ([23d2442](https://github.com/henry-hsieh/personal-setup/commit/23d24424e80e926c48c967b7b574017d04c7bb1f))
* **gh:** bump gh version to v2.83.1 ([#370](https://github.com/henry-hsieh/personal-setup/issues/370)) ([9b1af37](https://github.com/henry-hsieh/personal-setup/commit/9b1af379593d9cb0634d7b235ec331cc3ddd718b))
* **gh:** bump gh version to v2.83.2 ([#449](https://github.com/henry-hsieh/personal-setup/issues/449)) ([31687c6](https://github.com/henry-hsieh/personal-setup/commit/31687c676e908b7fb4cf459cb1c31988a6ff0774))
* **git-extras:** bump git-extras version to v7.4.0 ([#269](https://github.com/henry-hsieh/personal-setup/issues/269)) ([f6dcff1](https://github.com/henry-hsieh/personal-setup/commit/f6dcff1b790dd4ec0eb9f2a801a49fb1520414e3))
* **htop:** bump htop version to v3.4.1 ([#426](https://github.com/henry-hsieh/personal-setup/issues/426)) ([75dd611](https://github.com/henry-hsieh/personal-setup/commit/75dd6119fe406abd462978febc0931b9076d7607))
* **jdk:** bump jdk version to v21.0.7+6 ([#249](https://github.com/henry-hsieh/personal-setup/issues/249)) ([6c10a1c](https://github.com/henry-hsieh/personal-setup/commit/6c10a1c6fcaa7e773bf078333d7db0c482de326b))
* **jdk:** bump jdk version to v21.0.8+9 ([#277](https://github.com/henry-hsieh/personal-setup/issues/277)) ([c333e94](https://github.com/henry-hsieh/personal-setup/commit/c333e94da7899a259699683db1c3247a92a6d71f))
* **jdk:** bump jdk version to v25 ([#334](https://github.com/henry-hsieh/personal-setup/issues/334)) ([1fbee91](https://github.com/henry-hsieh/personal-setup/commit/1fbee91070f6cf5ee29f9db715c65d589ef1f79b))
* **jdk:** bump jdk version to v25.0.1+8 ([#353](https://github.com/henry-hsieh/personal-setup/issues/353)) ([9276418](https://github.com/henry-hsieh/personal-setup/commit/9276418d5f5550fb5368bc06f524fe399c435bb0))
* **lazygit:** bump lazygit version to v0.47.2 ([#236](https://github.com/henry-hsieh/personal-setup/issues/236)) ([b6a5530](https://github.com/henry-hsieh/personal-setup/commit/b6a55303307846f31f45bdfb2b501aaa1b68084e))
* **lazygit:** bump lazygit version to v0.48.0 ([#238](https://github.com/henry-hsieh/personal-setup/issues/238)) ([03485bb](https://github.com/henry-hsieh/personal-setup/commit/03485bb9ce1fee1b3f656b67a44f3d43842d1f10))
* **lazygit:** bump lazygit version to v0.49.0 ([#247](https://github.com/henry-hsieh/personal-setup/issues/247)) ([59c41e7](https://github.com/henry-hsieh/personal-setup/commit/59c41e7df51ef40e7b8307e3204be8b2254528ad))
* **lazygit:** bump lazygit version to v0.50.0 ([#253](https://github.com/henry-hsieh/personal-setup/issues/253)) ([8093bd0](https://github.com/henry-hsieh/personal-setup/commit/8093bd083afcc3b3ec1b3192bd1e1b779bac774d))
* **lazygit:** bump lazygit version to v0.51.1 ([#262](https://github.com/henry-hsieh/personal-setup/issues/262)) ([b8818f1](https://github.com/henry-hsieh/personal-setup/commit/b8818f1799835f72d5aea2ca38fc3263a900132d))
* **lazygit:** bump lazygit version to v0.52.0 ([#268](https://github.com/henry-hsieh/personal-setup/issues/268)) ([0d39f31](https://github.com/henry-hsieh/personal-setup/commit/0d39f313324e3fd045c2c7fa8cca75dd8ab9d0d5))
* **lazygit:** bump lazygit version to v0.53.0 ([#271](https://github.com/henry-hsieh/personal-setup/issues/271)) ([a9a7e15](https://github.com/henry-hsieh/personal-setup/commit/a9a7e1589e673329eaaa02d3c7d0371339fb9da0))
* **lazygit:** bump lazygit version to v0.54.0 ([#291](https://github.com/henry-hsieh/personal-setup/issues/291)) ([f3c525c](https://github.com/henry-hsieh/personal-setup/commit/f3c525c29b8cb7e59777fd1de6410b2b1b1d5c6a))
* **lazygit:** bump lazygit version to v0.54.1 ([#293](https://github.com/henry-hsieh/personal-setup/issues/293)) ([6c9d6f3](https://github.com/henry-hsieh/personal-setup/commit/6c9d6f334414396e6c0370ed989d882af83e3d37))
* **lazygit:** bump lazygit version to v0.54.2 ([#299](https://github.com/henry-hsieh/personal-setup/issues/299)) ([c168bf8](https://github.com/henry-hsieh/personal-setup/commit/c168bf85f8c8b7df2ac62f24933dffc98e5d4d7c))
* **lazygit:** bump lazygit version to v0.55.0 ([#330](https://github.com/henry-hsieh/personal-setup/issues/330)) ([5bfc8a0](https://github.com/henry-hsieh/personal-setup/commit/5bfc8a05e8a959989a77d3ea50e8d6427ae426c5))
* **lazygit:** bump lazygit version to v0.55.1 ([#333](https://github.com/henry-hsieh/personal-setup/issues/333)) ([84c3e52](https://github.com/henry-hsieh/personal-setup/commit/84c3e520ea1f521a7a233090d5f5ad66d183bd94))
* **lazygit:** bump lazygit version to v0.56.0 ([#361](https://github.com/henry-hsieh/personal-setup/issues/361)) ([5b745c4](https://github.com/henry-hsieh/personal-setup/commit/5b745c4837f05c0880255930372cab2d04294964))
* **lazygit:** bump lazygit version to v0.57.0 ([#441](https://github.com/henry-hsieh/personal-setup/issues/441)) ([9b21d61](https://github.com/henry-hsieh/personal-setup/commit/9b21d6196dbd36edc68a6ab5a64f1c837cf8c817))
* **nvim:** add genlint and bridge with nvim using nvim-lint ([#355](https://github.com/henry-hsieh/personal-setup/issues/355)) ([0705dfd](https://github.com/henry-hsieh/personal-setup/commit/0705dfdaeee82af03ba2e5c510e5fe5deebeaa06))
* **nvim:** add incremental selection for tree-sitter ([#350](https://github.com/henry-hsieh/personal-setup/issues/350)) ([7173ffb](https://github.com/henry-hsieh/personal-setup/commit/7173ffb4d06b47a032acabf4975a4269bc37f27b))
* **nvim:** add LazyFile event ([#354](https://github.com/henry-hsieh/personal-setup/issues/354)) ([2a52d1f](https://github.com/henry-hsieh/personal-setup/commit/2a52d1f01909af3f24f230b672cf26403c652346))
* **nvim:** add missing which-key groups ([#351](https://github.com/henry-hsieh/personal-setup/issues/351)) ([3350c42](https://github.com/henry-hsieh/personal-setup/commit/3350c42389081a3c734744256847688a1352d339))
* **nvim:** add nvim-ufo for pretty fold ([#301](https://github.com/henry-hsieh/personal-setup/issues/301)) ([e54c97b](https://github.com/henry-hsieh/personal-setup/commit/e54c97b3afb1cad2d4a98fcaba7ab843b15f7e0f))
* **nvim:** add snacks keys for GitHub CLI ([af2d10f](https://github.com/henry-hsieh/personal-setup/commit/af2d10f9ce85cd0c1071506f541b0af4ce543fd8))
* **nvim:** add trouble.nvim ([#324](https://github.com/henry-hsieh/personal-setup/issues/324)) ([b363493](https://github.com/henry-hsieh/personal-setup/commit/b3634936f59f46acfdd74e5804cae2d6233a40d2))
* **nvim:** add win keys for prompt in sidekick plugin ([#405](https://github.com/henry-hsieh/personal-setup/issues/405)) ([c19d1ae](https://github.com/henry-hsieh/personal-setup/commit/c19d1aecf1bac118a72f86e372486239722ffb24))
* **nvim:** add yazi.nvim ([#339](https://github.com/henry-hsieh/personal-setup/issues/339)) ([b2cb8cf](https://github.com/henry-hsieh/personal-setup/commit/b2cb8cf7c91bd93fdabcf213ac93329fcbbf38da))
* **nvim:** bump nvim version to v0.11.0 ([#243](https://github.com/henry-hsieh/personal-setup/issues/243)) ([835e10c](https://github.com/henry-hsieh/personal-setup/commit/835e10cb7f6be071fdd2bf6e747dd294f908ab7b))
* **nvim:** bump nvim version to v0.11.1 ([#252](https://github.com/henry-hsieh/personal-setup/issues/252)) ([adf4080](https://github.com/henry-hsieh/personal-setup/commit/adf4080758d7ab823fc5cb614e685c7add4efd3a))
* **nvim:** bump nvim version to v0.11.2 ([#267](https://github.com/henry-hsieh/personal-setup/issues/267)) ([a200e42](https://github.com/henry-hsieh/personal-setup/commit/a200e425b157699fc8cb45543deaec4f43fb814c))
* **nvim:** bump nvim version to v0.11.3 ([#279](https://github.com/henry-hsieh/personal-setup/issues/279)) ([0196989](https://github.com/henry-hsieh/personal-setup/commit/01969890d10d53bf1a844b21c42aeffd47aae443))
* **nvim:** bump nvim version to v0.11.4 ([#329](https://github.com/henry-hsieh/personal-setup/issues/329)) ([75da0c7](https://github.com/henry-hsieh/personal-setup/commit/75da0c74ce3dbe99345f812833192615f1ff9d78))
* **nvim:** bump nvim version to v0.11.5 ([#369](https://github.com/henry-hsieh/personal-setup/issues/369)) ([ce20a26](https://github.com/henry-hsieh/personal-setup/commit/ce20a267627c81d2068abb95d2b39c42957187da))
* **nvim:** change confirm keymap of snacks pickers ([#338](https://github.com/henry-hsieh/personal-setup/issues/338)) ([44e5883](https://github.com/henry-hsieh/personal-setup/commit/44e5883ec5a5ae4f18778f8cde60c424fa47c4fb))
* **nvim:** enhance lualine appearance ([#298](https://github.com/henry-hsieh/personal-setup/issues/298)) ([ab66472](https://github.com/henry-hsieh/personal-setup/commit/ab664724af2ea515f6fef1d0cd73f3d445d4f441))
* **nvim:** lazy load as much as possible ([#315](https://github.com/henry-hsieh/personal-setup/issues/315)) ([9364d0d](https://github.com/henry-hsieh/personal-setup/commit/9364d0d21b043b8f16b34ed7b4dffbd4656e2887))
* **nvim:** migrate from feline.nvim to lualine.nvim ([#296](https://github.com/henry-hsieh/personal-setup/issues/296)) ([8d31430](https://github.com/henry-hsieh/personal-setup/commit/8d3143036d009969ca3d6ee99e66149f2922e758))
* **nvim:** migrate from hop.nvim to flash.nvim ([#286](https://github.com/henry-hsieh/personal-setup/issues/286)) ([0cbef8b](https://github.com/henry-hsieh/personal-setup/commit/0cbef8b139b1d098c388dfd3c5d211f1343ef589))
* **nvim:** migrate from nvim-base16 to tinted-nvim ([#289](https://github.com/henry-hsieh/personal-setup/issues/289)) ([407d7bb](https://github.com/henry-hsieh/personal-setup/commit/407d7bb4b9561ff8cc34e3c45ccfc91a3ad5ac8a))
* **nvim:** migrate from nvim-cmp to blink.cmp ([#303](https://github.com/henry-hsieh/personal-setup/issues/303)) ([7a95c56](https://github.com/henry-hsieh/personal-setup/commit/7a95c566eaca229469bf6f6fb723f8db9d20305a))
* **nvim:** optimize nvim plugin settings ([#375](https://github.com/henry-hsieh/personal-setup/issues/375)) ([1be77d4](https://github.com/henry-hsieh/personal-setup/commit/1be77d47169f960132fe4b22143d196a6e562dc3))
* **nvim:** relink treesitter queries with relative path ([#310](https://github.com/henry-hsieh/personal-setup/issues/310)) ([2f197bc](https://github.com/henry-hsieh/personal-setup/commit/2f197bc10fca2d2144c087b4ea8603cf096700ee))
* **nvim:** replace ltex-ls with harper-ls ([#341](https://github.com/henry-hsieh/personal-setup/issues/341)) ([af811cc](https://github.com/henry-hsieh/personal-setup/commit/af811cc691051dcc3345f3e549f36d7c02c2022b))
* **nvim:** replace many plugins with snacks.nvim ([#307](https://github.com/henry-hsieh/personal-setup/issues/307)) ([329a518](https://github.com/henry-hsieh/personal-setup/commit/329a51874a9105538df31e0c82c203af725849d7))
* **nvim:** retire neoconf.nvim ([#314](https://github.com/henry-hsieh/personal-setup/issues/314)) ([270ce11](https://github.com/henry-hsieh/personal-setup/commit/270ce11ffacc68616dc74ef11fe7ffdee6a3b3a5))
* **nvim:** upgrade nvim-treesitter to new main branch ([#300](https://github.com/henry-hsieh/personal-setup/issues/300)) ([cacddc7](https://github.com/henry-hsieh/personal-setup/commit/cacddc7aedf22e28e7de7f2f4bc8a01f780acaee))
* **opencode:** bump opencode version to v1.0.104 ([#403](https://github.com/henry-hsieh/personal-setup/issues/403)) ([a9d2567](https://github.com/henry-hsieh/personal-setup/commit/a9d2567eff9a1714989f20ca10cebf8aa71fbe9d))
* **opencode:** bump opencode version to v1.0.105 ([#404](https://github.com/henry-hsieh/personal-setup/issues/404)) ([e10a500](https://github.com/henry-hsieh/personal-setup/commit/e10a5006f4c3623c754130e0e0253c904a75fde7))
* **opencode:** bump opencode version to v1.0.106 ([#408](https://github.com/henry-hsieh/personal-setup/issues/408)) ([8cf21f1](https://github.com/henry-hsieh/personal-setup/commit/8cf21f1fa851f53e8f6430e10ba54ec909f5244e))
* **opencode:** bump opencode version to v1.0.107 ([#410](https://github.com/henry-hsieh/personal-setup/issues/410)) ([c5052cc](https://github.com/henry-hsieh/personal-setup/commit/c5052ccddbefcc98a61fff2c3e5715f092eb6a17))
* **opencode:** bump opencode version to v1.0.108 ([#412](https://github.com/henry-hsieh/personal-setup/issues/412)) ([39d5715](https://github.com/henry-hsieh/personal-setup/commit/39d571585e313ce10a5abcd6ef99808131d26569))
* **opencode:** bump opencode version to v1.0.109 ([#413](https://github.com/henry-hsieh/personal-setup/issues/413)) ([a24f010](https://github.com/henry-hsieh/personal-setup/commit/a24f01038e94efac185d9066f2117623bfa15dc0))
* **opencode:** bump opencode version to v1.0.110 ([#415](https://github.com/henry-hsieh/personal-setup/issues/415)) ([76f9044](https://github.com/henry-hsieh/personal-setup/commit/76f9044de0846063ab0584d3ac86300022be15d6))
* **opencode:** bump opencode version to v1.0.112 ([#417](https://github.com/henry-hsieh/personal-setup/issues/417)) ([168f4b5](https://github.com/henry-hsieh/personal-setup/commit/168f4b504a5e25e306e3944de8de185fe2ed5ff5))
* **opencode:** bump opencode version to v1.0.114 ([#418](https://github.com/henry-hsieh/personal-setup/issues/418)) ([303414f](https://github.com/henry-hsieh/personal-setup/commit/303414f8b7e76061c70e048197c35e8ec7dd5ffc))
* **opencode:** bump opencode version to v1.0.115 ([#419](https://github.com/henry-hsieh/personal-setup/issues/419)) ([3e4159f](https://github.com/henry-hsieh/personal-setup/commit/3e4159fe1486f133116f3cfb5638085bb70c5e6a))
* **opencode:** bump opencode version to v1.0.117 ([#422](https://github.com/henry-hsieh/personal-setup/issues/422)) ([d4defd7](https://github.com/henry-hsieh/personal-setup/commit/d4defd7a0fcc324a459b97f3a2fdaddfde69b6e8))
* **opencode:** bump opencode version to v1.0.118 ([#423](https://github.com/henry-hsieh/personal-setup/issues/423)) ([97d69d0](https://github.com/henry-hsieh/personal-setup/commit/97d69d0c1384f61572f56f73ed2833e20a9f3d2f))
* **opencode:** bump opencode version to v1.0.119 ([#424](https://github.com/henry-hsieh/personal-setup/issues/424)) ([305567a](https://github.com/henry-hsieh/personal-setup/commit/305567a1f0b22b7d8fb406563f2491ae7f557a83))
* **opencode:** bump opencode version to v1.0.120 ([#427](https://github.com/henry-hsieh/personal-setup/issues/427)) ([16b37cb](https://github.com/henry-hsieh/personal-setup/commit/16b37cb963df3425689bb5851e2768265784076c))
* **opencode:** bump opencode version to v1.0.121 ([#429](https://github.com/henry-hsieh/personal-setup/issues/429)) ([13a3905](https://github.com/henry-hsieh/personal-setup/commit/13a3905ebe2e6dd38104a8fdddf0c84edd13cb29))
* **opencode:** bump opencode version to v1.0.122 ([#430](https://github.com/henry-hsieh/personal-setup/issues/430)) ([37d7da9](https://github.com/henry-hsieh/personal-setup/commit/37d7da91003fb63a831415248c96c115615946ea))
* **opencode:** bump opencode version to v1.0.123 ([#431](https://github.com/henry-hsieh/personal-setup/issues/431)) ([4a0faac](https://github.com/henry-hsieh/personal-setup/commit/4a0faac1ab7f2017a56d142f58205e404fde5660))
* **opencode:** bump opencode version to v1.0.124 ([#432](https://github.com/henry-hsieh/personal-setup/issues/432)) ([1822ef4](https://github.com/henry-hsieh/personal-setup/commit/1822ef408a760d85d44a46d5ae82e8e817a7ad4a))
* **opencode:** bump opencode version to v1.0.125 ([#434](https://github.com/henry-hsieh/personal-setup/issues/434)) ([404f7d6](https://github.com/henry-hsieh/personal-setup/commit/404f7d648b3fcec8ab87aa92f63c8b7524676e1a))
* **opencode:** bump opencode version to v1.0.126 ([#436](https://github.com/henry-hsieh/personal-setup/issues/436)) ([a976948](https://github.com/henry-hsieh/personal-setup/commit/a976948686aa27ffa9a3add05420cdd48cea7e77))
* **opencode:** bump opencode version to v1.0.137 ([#438](https://github.com/henry-hsieh/personal-setup/issues/438)) ([84b2fab](https://github.com/henry-hsieh/personal-setup/commit/84b2fabd210bc9d9ea4b00deeb7101bac9acaab7))
* **opencode:** bump opencode version to v1.0.138 ([#445](https://github.com/henry-hsieh/personal-setup/issues/445)) ([5edcb51](https://github.com/henry-hsieh/personal-setup/commit/5edcb5198fd38256f3953185787270d2fe7919d7))
* **opencode:** bump opencode version to v1.0.141 ([#446](https://github.com/henry-hsieh/personal-setup/issues/446)) ([dc7d199](https://github.com/henry-hsieh/personal-setup/commit/dc7d1993059075c687727a165fd4a526e7c610cf))
* **opencode:** bump opencode version to v1.0.143 ([#448](https://github.com/henry-hsieh/personal-setup/issues/448)) ([b54657a](https://github.com/henry-hsieh/personal-setup/commit/b54657afe7a0e9c50269f2b3b53da47209c70f85))
* **opencode:** bump opencode version to v1.0.146 ([#450](https://github.com/henry-hsieh/personal-setup/issues/450)) ([f68f1d7](https://github.com/henry-hsieh/personal-setup/commit/f68f1d7c26e67c3b49a32fc1c1f5403e82595185))
* **opencode:** bump opencode version to v1.0.150 ([#451](https://github.com/henry-hsieh/personal-setup/issues/451)) ([095a029](https://github.com/henry-hsieh/personal-setup/commit/095a029711bb34c919f3a6c764ff38b6b7d94626))
* **opencode:** bump opencode version to v1.0.152 ([#454](https://github.com/henry-hsieh/personal-setup/issues/454)) ([733113f](https://github.com/henry-hsieh/personal-setup/commit/733113f829dfbf3f77d83974ecd1c20df0d85955))
* **opencode:** bump opencode version to v1.0.80 ([#385](https://github.com/henry-hsieh/personal-setup/issues/385)) ([967f2c1](https://github.com/henry-hsieh/personal-setup/commit/967f2c1d21ed24bb0a1d268c1de8cd4ec9a84538))
* **opencode:** bump opencode version to v1.0.83 ([#386](https://github.com/henry-hsieh/personal-setup/issues/386)) ([ff7809d](https://github.com/henry-hsieh/personal-setup/commit/ff7809d25d144168f847c0102387fd52c7046c87))
* **opencode:** bump opencode version to v1.0.84 ([#387](https://github.com/henry-hsieh/personal-setup/issues/387)) ([3ccd75a](https://github.com/henry-hsieh/personal-setup/commit/3ccd75a4f0bf2279c4a6dd4a8ada78702371f8cb))
* **opencode:** bump opencode version to v1.0.85 ([#388](https://github.com/henry-hsieh/personal-setup/issues/388)) ([dae6415](https://github.com/henry-hsieh/personal-setup/commit/dae641592c0dc9094136742625fd35c7f1649c5a))
* **opencode:** bump opencode version to v1.0.90 ([#392](https://github.com/henry-hsieh/personal-setup/issues/392)) ([e9adede](https://github.com/henry-hsieh/personal-setup/commit/e9adede6afa001a3ad3e16d17cc97d1a88a50c93))
* **opencode:** bump opencode version to v1.0.93 ([#393](https://github.com/henry-hsieh/personal-setup/issues/393)) ([598f9ce](https://github.com/henry-hsieh/personal-setup/commit/598f9cedec3c03f17b37c5094ca7edd02cbc1483))
* **opencode:** bump opencode version to v1.0.98 ([#400](https://github.com/henry-hsieh/personal-setup/issues/400)) ([68bc0cd](https://github.com/henry-hsieh/personal-setup/commit/68bc0cd99bfb89f55901fa5bdc320d1f3b0f055c))
* **rg:** bump rg version to v15 ([#345](https://github.com/henry-hsieh/personal-setup/issues/345)) ([e4c347e](https://github.com/henry-hsieh/personal-setup/commit/e4c347e3f22384540344c87c294796171b6b7f32))
* **rg:** bump rg version to v15.1.0 ([#352](https://github.com/henry-hsieh/personal-setup/issues/352)) ([922af4c](https://github.com/henry-hsieh/personal-setup/commit/922af4c1e52f37683eea341e7c42682cc1d729c3))
* **rustup:** add rust-analyzer, rustfmt and clippy ([#294](https://github.com/henry-hsieh/personal-setup/issues/294)) ([6a1b31b](https://github.com/henry-hsieh/personal-setup/commit/6a1b31b93e8230fdb6e0c3a8de7c2f086cb7e1cd))
* **rustup:** bump rustup version to v1.28.0 ([#240](https://github.com/henry-hsieh/personal-setup/issues/240)) ([3767922](https://github.com/henry-hsieh/personal-setup/commit/3767922bf4adb74d13f4933163204300dfea1567))
* **rustup:** bump rustup version to v1.28.1 ([#242](https://github.com/henry-hsieh/personal-setup/issues/242)) ([e784211](https://github.com/henry-hsieh/personal-setup/commit/e78421117db54e8d5311dcfe7cc946aafd6084f3))
* **rustup:** bump rustup version to v1.28.2 ([#256](https://github.com/henry-hsieh/personal-setup/issues/256)) ([60cfe87](https://github.com/henry-hsieh/personal-setup/commit/60cfe879895238c6e6930767853f81db86d5e54b))
* **shell:** add jq as alias of yq ([#372](https://github.com/henry-hsieh/personal-setup/issues/372)) ([bc00477](https://github.com/henry-hsieh/personal-setup/commit/bc00477128e330e9835098835e17466958bf9e6c))
* **svlangserver:** install latest commit of svlangserver ([2d4de18](https://github.com/henry-hsieh/personal-setup/commit/2d4de18c715f452d6c2dd54537556a34a3058b5d))
* **tinty:** bump tinty version to v0.27.0 ([#244](https://github.com/henry-hsieh/personal-setup/issues/244)) ([6c4afa6](https://github.com/henry-hsieh/personal-setup/commit/6c4afa6de003bb8f4289f93cb01567ef3301abda))
* **tinty:** bump tinty version to v0.28.0 ([#276](https://github.com/henry-hsieh/personal-setup/issues/276)) ([351e416](https://github.com/henry-hsieh/personal-setup/commit/351e416972e06403c25591c605265b929cc95891))
* **tinty:** bump tinty version to v0.29.0 ([#288](https://github.com/henry-hsieh/personal-setup/issues/288)) ([d7d24d5](https://github.com/henry-hsieh/personal-setup/commit/d7d24d5c89a6c35fba287df0945eaed9caa34d63))
* **tinty:** update config.toml with new hooks and supported systems ([#416](https://github.com/henry-hsieh/personal-setup/issues/416)) ([affd527](https://github.com/henry-hsieh/personal-setup/commit/affd527dd0515b0626d944e7da53207af94f8ae2))
* **tmux:** bump tmux version to v3.6 ([#425](https://github.com/henry-hsieh/personal-setup/issues/425)) ([214a4d3](https://github.com/henry-hsieh/personal-setup/commit/214a4d3f21fa528e7c23bad21ea336c2984ab774))
* **tmux:** enable undercurl and extended keys ([#312](https://github.com/henry-hsieh/personal-setup/issues/312)) ([b75d809](https://github.com/henry-hsieh/personal-setup/commit/b75d809e662ac65d6ccbc7632f557bbcdb75f31d))
* **tree-sitter:** bump tree-sitter version to v0.25.10 ([#335](https://github.com/henry-hsieh/personal-setup/issues/335)) ([218bf09](https://github.com/henry-hsieh/personal-setup/commit/218bf09ab6b6200eaacbd527b3aeac79bff85b44))
* **tree-sitter:** bump tree-sitter version to v0.25.3 ([#241](https://github.com/henry-hsieh/personal-setup/issues/241)) ([3c6ed14](https://github.com/henry-hsieh/personal-setup/commit/3c6ed14162565c97013a5af617b9f59a5cef35db))
* **tree-sitter:** bump tree-sitter version to v0.25.4 ([#260](https://github.com/henry-hsieh/personal-setup/issues/260)) ([f580b1a](https://github.com/henry-hsieh/personal-setup/commit/f580b1a4e51f2f1e5f8c20e1344c5f02832e808e))
* **tree-sitter:** bump tree-sitter version to v0.25.5 ([#265](https://github.com/henry-hsieh/personal-setup/issues/265)) ([2efcd0d](https://github.com/henry-hsieh/personal-setup/commit/2efcd0d56de006674cfe3f21af48b828716e6e78))
* **tree-sitter:** bump tree-sitter version to v0.25.6 ([#266](https://github.com/henry-hsieh/personal-setup/issues/266)) ([556f0f0](https://github.com/henry-hsieh/personal-setup/commit/556f0f0f85615f978103842e28326b4cee9ea75b))
* **tree-sitter:** bump tree-sitter version to v0.25.7 ([#274](https://github.com/henry-hsieh/personal-setup/issues/274)) ([ba3f1fb](https://github.com/henry-hsieh/personal-setup/commit/ba3f1fb5ebfe39fc94069018f6d77e9adccf160a))
* **tree-sitter:** bump tree-sitter version to v0.25.8 ([#275](https://github.com/henry-hsieh/personal-setup/issues/275)) ([6ebf6f1](https://github.com/henry-hsieh/personal-setup/commit/6ebf6f14eed25ae896f3ff0355b52030b478259e))
* **tree-sitter:** bump tree-sitter version to v0.25.9 ([#331](https://github.com/henry-hsieh/personal-setup/issues/331)) ([54bbf82](https://github.com/henry-hsieh/personal-setup/commit/54bbf82ef42691ad016771f230dbe8b7aa93b603))
* **tree-sitter:** bump tree-sitter version to v0.26.2 ([#444](https://github.com/henry-hsieh/personal-setup/issues/444)) ([fbf56f4](https://github.com/henry-hsieh/personal-setup/commit/fbf56f4baffb442f1c191164ffa0e77c0b0bdd82))
* **tree-sitter:** bump tree-sitter version to v0.26.3 ([#455](https://github.com/henry-hsieh/personal-setup/issues/455)) ([737cdda](https://github.com/henry-hsieh/personal-setup/commit/737cddae155fa75443d58fdd8c10618a03d7db47))
* **wezterm:** add wezterm ([#327](https://github.com/henry-hsieh/personal-setup/issues/327)) ([9309bf3](https://github.com/henry-hsieh/personal-setup/commit/9309bf3fbc537a86e53467c255ba7fc88cf66f23))
* **wezterm:** bump wezterm version to v20250909 ([#337](https://github.com/henry-hsieh/personal-setup/issues/337)) ([5d7a9a3](https://github.com/henry-hsieh/personal-setup/commit/5d7a9a3ceae42d0d3c8f51252dc2778a095dcbe9))
* **wezterm:** bump wezterm version to v20251014 ([#344](https://github.com/henry-hsieh/personal-setup/issues/344)) ([b4bf040](https://github.com/henry-hsieh/personal-setup/commit/b4bf040517709169e6cae049a2809c1dfe3d5263))
* **wezterm:** bump wezterm version to v20251025 ([#356](https://github.com/henry-hsieh/personal-setup/issues/356)) ([7ac737c](https://github.com/henry-hsieh/personal-setup/commit/7ac737cf0890407332cdbd74fc16e075ba59e354))
* **wezterm:** bump wezterm version to v20251111 ([#368](https://github.com/henry-hsieh/personal-setup/issues/368)) ([647c755](https://github.com/henry-hsieh/personal-setup/commit/647c755fedfb8524624b532e55e527fa9e17fe0a))
* **wezterm:** bump wezterm version to v20251123 ([#409](https://github.com/henry-hsieh/personal-setup/issues/409)) ([5b82768](https://github.com/henry-hsieh/personal-setup/commit/5b82768fe6331dff601386bbd71ddc6e44796a7e))
* **wezterm:** bump wezterm version to v20251201 ([#435](https://github.com/henry-hsieh/personal-setup/issues/435)) ([7a5935a](https://github.com/henry-hsieh/personal-setup/commit/7a5935a8e317950f62111b0886d3121bb28ed76e))
* **yazi:** add shell helpers ([#322](https://github.com/henry-hsieh/personal-setup/issues/322)) ([55a5a6c](https://github.com/henry-hsieh/personal-setup/commit/55a5a6c1f145bc684fb40e8d12166b921b4d445c))
* **yazi:** add yazi for file explorer ([#321](https://github.com/henry-hsieh/personal-setup/issues/321)) ([5d8a851](https://github.com/henry-hsieh/personal-setup/commit/5d8a85129080e25943eb0828ea9bd3960b454996))
* **yq:** bump yq version to v4.45.2 ([#254](https://github.com/henry-hsieh/personal-setup/issues/254)) ([41275c1](https://github.com/henry-hsieh/personal-setup/commit/41275c143cbcf6a90428dbb41336bbfd7ca11dcf))
* **yq:** bump yq version to v4.45.3 ([#257](https://github.com/henry-hsieh/personal-setup/issues/257)) ([fbd260b](https://github.com/henry-hsieh/personal-setup/commit/fbd260bdfbe62fcd3ef26696759c002a8e6a7a6b))
* **yq:** bump yq version to v4.45.4 ([#259](https://github.com/henry-hsieh/personal-setup/issues/259)) ([02badf4](https://github.com/henry-hsieh/personal-setup/commit/02badf40c130b93b7ea11cb3169960815b926624))
* **yq:** bump yq version to v4.46.1 ([#273](https://github.com/henry-hsieh/personal-setup/issues/273)) ([16e951f](https://github.com/henry-hsieh/personal-setup/commit/16e951f3b543ad9b43a29739a487f4facc9888e6))
* **yq:** bump yq version to v4.47.1 ([#283](https://github.com/henry-hsieh/personal-setup/issues/283)) ([40424bc](https://github.com/henry-hsieh/personal-setup/commit/40424bc747f713cc6d13e84bef37dfc53e03485f))
* **yq:** bump yq version to v4.47.2 ([#332](https://github.com/henry-hsieh/personal-setup/issues/332)) ([c203138](https://github.com/henry-hsieh/personal-setup/commit/c203138009f4333ab7a597b39318e7678cfda2cc))
* **yq:** bump yq version to v4.48.1 ([#342](https://github.com/henry-hsieh/personal-setup/issues/342)) ([056a299](https://github.com/henry-hsieh/personal-setup/commit/056a299ee1da88470380897e26e4af26d6b1369e))
* **yq:** bump yq version to v4.48.2 ([#371](https://github.com/henry-hsieh/personal-setup/issues/371)) ([dd976d9](https://github.com/henry-hsieh/personal-setup/commit/dd976d9cac42c269a61ea99e338688030ed50aac))
* **yq:** bump yq version to v4.49.1 ([#401](https://github.com/henry-hsieh/personal-setup/issues/401)) ([feee353](https://github.com/henry-hsieh/personal-setup/commit/feee3534c2854ed41b2ccccb85d8da6af0d2bda2))
* **yq:** bump yq version to v4.49.2 ([#414](https://github.com/henry-hsieh/personal-setup/issues/414)) ([2e12b1b](https://github.com/henry-hsieh/personal-setup/commit/2e12b1be3724f470e234b0c9e0611012d77c1e1c))
* **zoxide:** add initialization scripts ([#317](https://github.com/henry-hsieh/personal-setup/issues/317)) ([8016af4](https://github.com/henry-hsieh/personal-setup/commit/8016af435882461f819f90dc7ba2f046e1b8ef44))
* **zoxide:** use zoxide to replace bd and goto ([#316](https://github.com/henry-hsieh/personal-setup/issues/316)) ([d3224e7](https://github.com/henry-hsieh/personal-setup/commit/d3224e7ac75c474a8101d08a07a527764218cc95))


### Bug Fixes

* **bash:** remove goto script from .bashrc ([#358](https://github.com/henry-hsieh/personal-setup/issues/358)) ([3721c7e](https://github.com/henry-hsieh/personal-setup/commit/3721c7e5b7d940a159247108a15aed5c5e264d2f))
* **cargo:** completion generate command error ([#311](https://github.com/henry-hsieh/personal-setup/issues/311)) ([f7877eb](https://github.com/henry-hsieh/personal-setup/commit/f7877eb3624e72e9b345c199899815c8fc23fbc6))
* **crush:** typo for installing manpages ([#394](https://github.com/henry-hsieh/personal-setup/issues/394)) ([fe2bc0a](https://github.com/henry-hsieh/personal-setup/commit/fe2bc0a61f544f0cb2378640eb02e157c8f13ea9))
* enable offline SDK packaging for OpenCode ([#389](https://github.com/henry-hsieh/personal-setup/issues/389)) ([2a1c49d](https://github.com/henry-hsieh/personal-setup/commit/2a1c49d6af7bf751894799986242e11dc7981ae2))
* **install:** preserve installation path permission ([#349](https://github.com/henry-hsieh/personal-setup/issues/349)) ([25528b5](https://github.com/henry-hsieh/personal-setup/commit/25528b5ffb7c34e43da68ae457de1c7d859f7fcf))
* lua-language-server setup and treesitter jsonc removal ([#442](https://github.com/henry-hsieh/personal-setup/issues/442)) ([7735e7c](https://github.com/henry-hsieh/personal-setup/commit/7735e7c365cb193bcc5c7c252a0df8a31e87fa3a))
* **nvim:** blink.cmp version check should not have newline ([#318](https://github.com/henry-hsieh/personal-setup/issues/318)) ([094fc3d](https://github.com/henry-hsieh/personal-setup/commit/094fc3d2b54b329ddb166e47e18cec92046bd1eb))
* **nvim:** change accept key to &lt;C-y&gt; to avoid &lt;CR&gt; accidentally sent ([#304](https://github.com/henry-hsieh/personal-setup/issues/304)) ([5bddd23](https://github.com/henry-hsieh/personal-setup/commit/5bddd235bff3da764f7bcd9ec5624e1b521e3514))
* **nvim:** change dependency repo of snacks back to origin ([#365](https://github.com/henry-hsieh/personal-setup/issues/365)) ([0a9e592](https://github.com/henry-hsieh/personal-setup/commit/0a9e5929b4566495323ec5b84189652d2b6153b8))
* **nvim:** cleanup nvim-cmp settings ([#306](https://github.com/henry-hsieh/personal-setup/issues/306)) ([5498388](https://github.com/henry-hsieh/personal-setup/commit/5498388153a4a1e255c9394f65a26c61ea643a5d))
* **nvim:** cleanup telescope-settings ([#308](https://github.com/henry-hsieh/personal-setup/issues/308)) ([d549352](https://github.com/henry-hsieh/personal-setup/commit/d549352b7cc7d20330321e2fd7fea4a0e0948744))
* **nvim:** disable nvim-lint when open yazi ([#359](https://github.com/henry-hsieh/personal-setup/issues/359)) ([7eee6b3](https://github.com/henry-hsieh/personal-setup/commit/7eee6b3c27cc1bbabbe4ac99b3dab3d7ed7dc725))
* **nvim:** download blink.cmp fuzzy prebuilt binaries ([#309](https://github.com/henry-hsieh/personal-setup/issues/309)) ([0c49c7f](https://github.com/henry-hsieh/personal-setup/commit/0c49c7f6ec37bd7c34d2a15d2853e2e2b67e98c4))
* **nvim:** fix the highlight of statusline generated by trouble.nvim ([#367](https://github.com/henry-hsieh/personal-setup/issues/367)) ([85e2408](https://github.com/henry-hsieh/personal-setup/commit/85e2408daaf95afc46d003de94c44982a6274b6c))
* **nvim:** improve appearance ([#302](https://github.com/henry-hsieh/personal-setup/issues/302)) ([0663209](https://github.com/henry-hsieh/personal-setup/commit/0663209249fbcb646bbbb0dfcab8dd7a8a73618e))
* **nvim:** mason upgrade error ([#261](https://github.com/henry-hsieh/personal-setup/issues/261)) ([3c33370](https://github.com/henry-hsieh/personal-setup/commit/3c33370c2e7a76a7abde83a11698a2684fa8a0e6))
* **nvim:** navigation in diff mode ([#258](https://github.com/henry-hsieh/personal-setup/issues/258)) ([a0b37b2](https://github.com/henry-hsieh/personal-setup/commit/a0b37b2c11a139aa3561d4cc2b7f072833d175a1))
* **nvim:** only use nvim-treesitter indent when available ([#305](https://github.com/henry-hsieh/personal-setup/issues/305)) ([5e27ac9](https://github.com/henry-hsieh/personal-setup/commit/5e27ac978e802f479b609034a77fb65c47e86720))
* **nvim:** open lazygit with git root of current buffer ([#313](https://github.com/henry-hsieh/personal-setup/issues/313)) ([f88776c](https://github.com/henry-hsieh/personal-setup/commit/f88776ca631e704463eabade3313bf726a8e5c07))
* **nvim:** register tree-sitter for verilog_systemverilog ([#360](https://github.com/henry-hsieh/personal-setup/issues/360)) ([65a8397](https://github.com/henry-hsieh/personal-setup/commit/65a839702fb9fe890d6c9d9daea932a64716ba5e))
* **nvim:** remove redundant diagnostic component of lualine ([#297](https://github.com/henry-hsieh/personal-setup/issues/297)) ([e7efa52](https://github.com/henry-hsieh/personal-setup/commit/e7efa52d1831c65c9f4a579ad120518bee0a526e))
* **nvim:** separate pick_win and confirm key in snacks ([#364](https://github.com/henry-hsieh/personal-setup/issues/364)) ([1f93bef](https://github.com/henry-hsieh/personal-setup/commit/1f93bef5ffd966d11ef450dc9abb35c0fd4d0485))
* **nvim:** snacks lazygit command ([#340](https://github.com/henry-hsieh/personal-setup/issues/340)) ([40098f8](https://github.com/henry-hsieh/personal-setup/commit/40098f8c6864ed38785ec8b8cf957b1d2dc68908))
* **nvim:** snacks picker confirm keys ([#347](https://github.com/henry-hsieh/personal-setup/issues/347)) ([044c261](https://github.com/henry-hsieh/personal-setup/commit/044c261ef8c01ac031a4c7db2ee6c5cd2cf91fe0))
* **nvim:** stop loading removed module ([#287](https://github.com/henry-hsieh/personal-setup/issues/287)) ([0e2e971](https://github.com/henry-hsieh/personal-setup/commit/0e2e97163b592ed5718a65199563fdc463566798))
* **nvim:** update flash settings for better control ([#295](https://github.com/henry-hsieh/personal-setup/issues/295)) ([d8dd67f](https://github.com/henry-hsieh/personal-setup/commit/d8dd67fcb0ffd32a8fd8bf02d84cf220c8011079))
* **nvim:** verible shows duplicated diagnostics ([#378](https://github.com/henry-hsieh/personal-setup/issues/378)) ([212e13b](https://github.com/henry-hsieh/personal-setup/commit/212e13b9e1b27040c7bd0babfd3a0a99a12ae6c6))
* **shell:** no need to set display in new WSL version ([#320](https://github.com/henry-hsieh/personal-setup/issues/320)) ([f67e07c](https://github.com/henry-hsieh/personal-setup/commit/f67e07c31ec8509be70d04f9e98f4d4490b01125))


### Code Refactoring

* **nvim:** update nvim-lspconfig to Nvim 0.11+ settings ([#290](https://github.com/henry-hsieh/personal-setup/issues/290)) ([683adbe](https://github.com/henry-hsieh/personal-setup/commit/683adbe4eba02e35a30056a809e7d3f279daf404))


### Build System

* migrate to Ubuntu 18.04 ([#326](https://github.com/henry-hsieh/personal-setup/issues/326)) ([7527a0c](https://github.com/henry-hsieh/personal-setup/commit/7527a0c7e9de7ba88465e9af59ade8966cf9712f))

## [1.10.0](https://github.com/henry-hsieh/personal-setup/compare/v1.9.0...v1.10.0) (2025-02-23)


### Features

* **bat:** bump bat version to v0.25.0 ([#206](https://github.com/henry-hsieh/personal-setup/issues/206)) ([feb5885](https://github.com/henry-hsieh/personal-setup/commit/feb58855d1b5dd1db626351883ccc5f67bc0c926))
* **fzf-tab-comp:** bump fzf-tab-comp digest to 4850357 ([#215](https://github.com/henry-hsieh/personal-setup/issues/215)) ([30d3b25](https://github.com/henry-hsieh/personal-setup/commit/30d3b250240af0329553f4073b32747b7751ef95))
* **fzf:** bump fzf version to v0.57.0 ([#201](https://github.com/henry-hsieh/personal-setup/issues/201)) ([47144df](https://github.com/henry-hsieh/personal-setup/commit/47144df0532c54986e47ef748a3dec932efee25c))
* **fzf:** bump fzf version to v0.58.0 ([#214](https://github.com/henry-hsieh/personal-setup/issues/214)) ([0b4a9ca](https://github.com/henry-hsieh/personal-setup/commit/0b4a9cab05eea2f1fb33d929da63191e6e78d817))
* **fzf:** bump fzf version to v0.59.0 ([#221](https://github.com/henry-hsieh/personal-setup/issues/221)) ([8591df2](https://github.com/henry-hsieh/personal-setup/commit/8591df242c6097860ea5664f3491dcbcd10f560d))
* **fzf:** bump fzf version to v0.60.0 ([#229](https://github.com/henry-hsieh/personal-setup/issues/229)) ([dd9311e](https://github.com/henry-hsieh/personal-setup/commit/dd9311e9298e242ef0c10dea78a61eb4425d692b))
* **fzf:** bump fzf version to v0.60.1 ([#233](https://github.com/henry-hsieh/personal-setup/issues/233)) ([348ff3a](https://github.com/henry-hsieh/personal-setup/commit/348ff3a9c66e8d24ddf2a802528ef5b0a73449ec))
* **fzf:** bump fzf version to v0.60.2 ([#235](https://github.com/henry-hsieh/personal-setup/issues/235)) ([c8d81b0](https://github.com/henry-hsieh/personal-setup/commit/c8d81b04a921819d06b0344a684b849e7864ff8e))
* **jdk:** bump jdk version to v21.0.6+7 ([#217](https://github.com/henry-hsieh/personal-setup/issues/217)) ([5b3bf48](https://github.com/henry-hsieh/personal-setup/commit/5b3bf48c3d37424ea36a30f32aa68220bf80a0bf))
* **lazygit:** bump lazygit version to v0.45.0 ([#208](https://github.com/henry-hsieh/personal-setup/issues/208)) ([d18d077](https://github.com/henry-hsieh/personal-setup/commit/d18d077bb2d10000675bb72707f526e1d3076e9d))
* **lazygit:** bump lazygit version to v0.45.2 ([#212](https://github.com/henry-hsieh/personal-setup/issues/212)) ([b6c965c](https://github.com/henry-hsieh/personal-setup/commit/b6c965cb1cd1b1b02782aaef36cde4c01a5a07f1))
* **lazygit:** bump lazygit version to v0.46.0 ([#231](https://github.com/henry-hsieh/personal-setup/issues/231)) ([0560ed8](https://github.com/henry-hsieh/personal-setup/commit/0560ed8095761746a335fd4431c08678554c8e55))
* **lazygit:** bump lazygit version to v0.47.1 ([#234](https://github.com/henry-hsieh/personal-setup/issues/234)) ([114b94f](https://github.com/henry-hsieh/personal-setup/commit/114b94f41665ad3fbdafb13fd7bec7da5d7f9532))
* **node:** bump node version to v23.4.0 ([#199](https://github.com/henry-hsieh/personal-setup/issues/199)) ([9cbc162](https://github.com/henry-hsieh/personal-setup/commit/9cbc162def8865f006f562db119ba9fb9a810f08))
* **node:** bump node version to v23.5.0 ([#202](https://github.com/henry-hsieh/personal-setup/issues/202)) ([ed2f75d](https://github.com/henry-hsieh/personal-setup/commit/ed2f75dbc8da77cd48c9d0797d49bb3dc6253445))
* **node:** bump node version to v23.6.0 ([#207](https://github.com/henry-hsieh/personal-setup/issues/207)) ([281263a](https://github.com/henry-hsieh/personal-setup/commit/281263a371ed157d29f7a5a6a8870cf472cb94be))
* **node:** bump node version to v23.6.1 ([#216](https://github.com/henry-hsieh/personal-setup/issues/216)) ([96c914f](https://github.com/henry-hsieh/personal-setup/commit/96c914f3f4d4d8e2fc26c87b08fe98d602ab9faa))
* **node:** bump node version to v23.7.0 ([#219](https://github.com/henry-hsieh/personal-setup/issues/219)) ([d3b50d2](https://github.com/henry-hsieh/personal-setup/commit/d3b50d258095b099b05097ec671f8ce38e60addc))
* **nvim:** add options for ignore specified dirs ([#228](https://github.com/henry-hsieh/personal-setup/issues/228)) ([24023bf](https://github.com/henry-hsieh/personal-setup/commit/24023bfaded1bbbdbe2633a2b4ab5ee48b0d5aab))
* **nvim:** add winbar of feline.nvim and detour.nvim ([#225](https://github.com/henry-hsieh/personal-setup/issues/225)) ([5037cf9](https://github.com/henry-hsieh/personal-setup/commit/5037cf971e4226f66be9e3987a75bb182fb0e0af))
* **nvim:** auto reload opened buffers when terminal is closed ([#224](https://github.com/henry-hsieh/personal-setup/issues/224)) ([e69bd65](https://github.com/henry-hsieh/personal-setup/commit/e69bd654a7dc1d839ec505485db70d1ec3dc8819))
* **nvim:** bump nvim version to v0.10.3 ([#205](https://github.com/henry-hsieh/personal-setup/issues/205)) ([47f8984](https://github.com/henry-hsieh/personal-setup/commit/47f8984c5bac2e3e7265554ad6ea2b72376d8732))
* **nvim:** bump nvim version to v0.10.4 ([#218](https://github.com/henry-hsieh/personal-setup/issues/218)) ([007a52e](https://github.com/henry-hsieh/personal-setup/commit/007a52ec4a2dab40b101383da9ad3840ac34ab26))
* **nvim:** replace bufferline.nvim with tabby.nvim ([#226](https://github.com/henry-hsieh/personal-setup/issues/226)) ([63883c5](https://github.com/henry-hsieh/personal-setup/commit/63883c5e6395c60b348b2253bbcaa0b80aec1486))
* **nvim:** use global statusline ([#227](https://github.com/henry-hsieh/personal-setup/issues/227)) ([8e8247d](https://github.com/henry-hsieh/personal-setup/commit/8e8247d9b8300b6fb59c02d9c7a2bc581e759af7))
* **tinty:** bump tinty version to v0.24.0 ([#203](https://github.com/henry-hsieh/personal-setup/issues/203)) ([230c070](https://github.com/henry-hsieh/personal-setup/commit/230c070cd0680189775d7464cf8d9f06fbf7bea1))
* **tinty:** bump tinty version to v0.25.0 ([#211](https://github.com/henry-hsieh/personal-setup/issues/211)) ([72294b0](https://github.com/henry-hsieh/personal-setup/commit/72294b047ce2d59374aee8a2681ba834870e2c69))
* **tinty:** bump tinty version to v0.26.0 ([#213](https://github.com/henry-hsieh/personal-setup/issues/213)) ([9873fb7](https://github.com/henry-hsieh/personal-setup/commit/9873fb7156a9cdffde552eaa38a1e5543bff3ff8))
* **tinty:** bump tinty version to v0.26.1 ([#230](https://github.com/henry-hsieh/personal-setup/issues/230)) ([7bba8a6](https://github.com/henry-hsieh/personal-setup/commit/7bba8a620653b15660a0426b69fb1c4e0a9f6adc))
* **tree-sitter:** bump tree-sitter version to v0.24.5 ([#200](https://github.com/henry-hsieh/personal-setup/issues/200)) ([f5ea7f8](https://github.com/henry-hsieh/personal-setup/commit/f5ea7f877a479d42a10fbe6432106226535ebe90))
* **tree-sitter:** bump tree-sitter version to v0.24.6 ([#204](https://github.com/henry-hsieh/personal-setup/issues/204)) ([9dab47c](https://github.com/henry-hsieh/personal-setup/commit/9dab47c1e295340d5c59c6a866ff56a5a269cd8d))
* **tree-sitter:** bump tree-sitter version to v0.24.7 ([#210](https://github.com/henry-hsieh/personal-setup/issues/210)) ([74339af](https://github.com/henry-hsieh/personal-setup/commit/74339afac34747df3971605809852204915f8bce))
* **tree-sitter:** bump tree-sitter version to v0.25.1 ([#220](https://github.com/henry-hsieh/personal-setup/issues/220)) ([4d10eb5](https://github.com/henry-hsieh/personal-setup/commit/4d10eb574562f874513cea105d73798997365068))
* **tree-sitter:** bump tree-sitter version to v0.25.2 ([#232](https://github.com/henry-hsieh/personal-setup/issues/232)) ([b124749](https://github.com/henry-hsieh/personal-setup/commit/b124749995647c546b9d6ece97575ca1258ff23a))
* **yq:** bump yq version to v4.44.6 ([#197](https://github.com/henry-hsieh/personal-setup/issues/197)) ([5d2d679](https://github.com/henry-hsieh/personal-setup/commit/5d2d67973ec71d633f7237021e7261930dc92370))
* **yq:** bump yq version to v4.45.1 ([#209](https://github.com/henry-hsieh/personal-setup/issues/209)) ([2396108](https://github.com/henry-hsieh/personal-setup/commit/2396108c6938ab9a9a7b19462ec832a430794543))


### Bug Fixes

* **build:** create man1 directory before calling rsync ([#223](https://github.com/henry-hsieh/personal-setup/issues/223)) ([7034ac5](https://github.com/henry-hsieh/personal-setup/commit/7034ac5d4ff33703edb39bb21ab10fc1173e9e30))
* **nvim:** change feline.nvim back to archived version ([#222](https://github.com/henry-hsieh/personal-setup/issues/222)) ([06d9cad](https://github.com/henry-hsieh/personal-setup/commit/06d9cadd4f6525884c513c9a3062d85ce075e2d7))

## [1.9.0](https://github.com/henry-hsieh/personal-setup/compare/v1.8.0...v1.9.0) (2024-12-05)


### Features

* **fzf-tab-comp:** bump fzf-tab-comp digest to 3e9ff06 ([#194](https://github.com/henry-hsieh/personal-setup/issues/194)) ([8114e19](https://github.com/henry-hsieh/personal-setup/commit/8114e1912f02ce7782d5d2d05f7aac6f97e1b78d))
* **fzf-tab-comp:** bump fzf-tab-comp digest to 5bbbf61 ([#191](https://github.com/henry-hsieh/personal-setup/issues/191)) ([0ffb8e6](https://github.com/henry-hsieh/personal-setup/commit/0ffb8e6391762109e9c03b2b84c12ea90995bd98))
* **fzf-tab-comp:** bump fzf-tab-comp digest to 5ff8ab0 ([#195](https://github.com/henry-hsieh/personal-setup/issues/195)) ([ca16842](https://github.com/henry-hsieh/personal-setup/commit/ca16842ccb5e812f5aabf3c420a9c62d479af0a4))
* **fzf-tab-comp:** bump fzf-tab-comp digest to 7979a16 ([#192](https://github.com/henry-hsieh/personal-setup/issues/192)) ([eb5cd99](https://github.com/henry-hsieh/personal-setup/commit/eb5cd99ae810dabcf2da25b11347f279d14ad7a1))
* **fzf:** bump fzf version to v0.56.3 ([#186](https://github.com/henry-hsieh/personal-setup/issues/186)) ([dce29ac](https://github.com/henry-hsieh/personal-setup/commit/dce29acf58301d085423262b8cf5c3b58bcd5806))
* **node:** bump node version to v23.2.0 ([#188](https://github.com/henry-hsieh/personal-setup/issues/188)) ([44dd31f](https://github.com/henry-hsieh/personal-setup/commit/44dd31f8d90c6f55fb7071b1c3632f64b81cc653))
* **node:** bump node version to v23.3.0 ([#193](https://github.com/henry-hsieh/personal-setup/issues/193)) ([9ad129c](https://github.com/henry-hsieh/personal-setup/commit/9ad129c46cf294ef109dd9d5d255babd3ef333aa))
* **nvim:** add keymap for wrapping toggle ([#196](https://github.com/henry-hsieh/personal-setup/issues/196)) ([226c7b5](https://github.com/henry-hsieh/personal-setup/commit/226c7b543f7a25df148458cf1b23d28bf27d847c))
* **tinty:** bump tinty version to v0.23.0 ([#190](https://github.com/henry-hsieh/personal-setup/issues/190)) ([0b66c1e](https://github.com/henry-hsieh/personal-setup/commit/0b66c1e5eacef4d048ed861bd2dd5ce2bd298a79))
* **yq:** bump yq version to v4.44.5 ([#189](https://github.com/henry-hsieh/personal-setup/issues/189)) ([a3e6f1a](https://github.com/henry-hsieh/personal-setup/commit/a3e6f1aaffe2c6554738ceb8e5f6d9665d2b2073))

## [1.8.0](https://github.com/henry-hsieh/personal-setup/compare/v1.7.1...v1.8.0) (2024-11-11)


### Features

* **fzf:** bump fzf version to v0.56.0 ([#182](https://github.com/henry-hsieh/personal-setup/issues/182)) ([06549e2](https://github.com/henry-hsieh/personal-setup/commit/06549e24f45cb2a134fbc0ba148f1087e393b010))
* **fzf:** bump fzf version to v0.56.1 ([#184](https://github.com/henry-hsieh/personal-setup/issues/184)) ([5cb68d7](https://github.com/henry-hsieh/personal-setup/commit/5cb68d763104109b673475cab3543239419aacd5))
* **fzf:** bump fzf version to v0.56.2 ([#185](https://github.com/henry-hsieh/personal-setup/issues/185)) ([93b7cc0](https://github.com/henry-hsieh/personal-setup/commit/93b7cc0cbaef1c0bfc9eb61ae04d58bd54897b00))
* **git-extras:** bump git-extras version to v7.3.0 ([#178](https://github.com/henry-hsieh/personal-setup/issues/178)) ([5e60583](https://github.com/henry-hsieh/personal-setup/commit/5e60583b0d24fd16d2abdf169e76e635d8ec7886))
* **jdk:** bump jdk version to v21.0.5+11 ([#175](https://github.com/henry-hsieh/personal-setup/issues/175)) ([53ca716](https://github.com/henry-hsieh/personal-setup/commit/53ca716fa45f283c9b0bff525258aee0a5aac85d))
* **node:** bump node version to v23 ([#176](https://github.com/henry-hsieh/personal-setup/issues/176)) ([7b34af8](https://github.com/henry-hsieh/personal-setup/commit/7b34af8523fbb02a6439262777b12fdc22393dd7))
* **node:** bump node version to v23.1.0 ([#181](https://github.com/henry-hsieh/personal-setup/issues/181)) ([938c7ab](https://github.com/henry-hsieh/personal-setup/commit/938c7ab7e89214028f622c2906444cfb95c2f42c))
* **tree-sitter:** bump tree-sitter version to v0.24.4 ([#183](https://github.com/henry-hsieh/personal-setup/issues/183)) ([1b6d189](https://github.com/henry-hsieh/personal-setup/commit/1b6d18943d420b5eb53fc370a3c72d925bcc8c02))


### Bug Fixes

* **nvim:** add verible.filelist as root_pattern of verible ([#180](https://github.com/henry-hsieh/personal-setup/issues/180)) ([5ab31ee](https://github.com/henry-hsieh/personal-setup/commit/5ab31ee200fc714518379502bee0b950a4b96ea4))
* **nvim:** make sure neoconf.nvim is loaded before nvim-lspconfig ([#179](https://github.com/henry-hsieh/personal-setup/issues/179)) ([4304158](https://github.com/henry-hsieh/personal-setup/commit/430415828a1707484769015ba03c4287be9c54aa))

## [1.7.1](https://github.com/henry-hsieh/personal-setup/compare/v1.7.0...v1.7.1) (2024-10-16)


### Bug Fixes

* **nvim:** change nvim-tree to release version ([#173](https://github.com/henry-hsieh/personal-setup/issues/173)) ([95740cf](https://github.com/henry-hsieh/personal-setup/commit/95740cf984dc15f1a080059303cab30fd575508d))

## [1.7.0](https://github.com/henry-hsieh/personal-setup/compare/v1.6.2...v1.7.0) (2024-10-09)


### Features

* **jdk:** use LTS JDK released by adoptium ([#155](https://github.com/henry-hsieh/personal-setup/issues/155)) ([658dc04](https://github.com/henry-hsieh/personal-setup/commit/658dc044bea5f21c036288bca8bf049067ef6457))
* **lazygit:** bump lazygit version to v0.44.1 ([#153](https://github.com/henry-hsieh/personal-setup/issues/153)) ([958d53d](https://github.com/henry-hsieh/personal-setup/commit/958d53d805acfec9cf4a74ab1962ae6f91cf1c7c))
* **node:** bump node version to v22.9.0 ([#151](https://github.com/henry-hsieh/personal-setup/issues/151)) ([1bfa3ea](https://github.com/henry-hsieh/personal-setup/commit/1bfa3ea6d3058bb1eee15268e4d246876ce86c13))
* **nvim:** bump nvim version to v0.10.2 ([#168](https://github.com/henry-hsieh/personal-setup/issues/168)) ([2496d93](https://github.com/henry-hsieh/personal-setup/commit/2496d939049f85920c3d53629dfe2823b821dafe))
* **tinty:** bump tinty version to v0.19.0 ([#160](https://github.com/henry-hsieh/personal-setup/issues/160)) ([eb19a1f](https://github.com/henry-hsieh/personal-setup/commit/eb19a1f55144187ad45f1664caa60723dbeb1489))
* **tinty:** bump tinty version to v0.20.0 ([#161](https://github.com/henry-hsieh/personal-setup/issues/161)) ([47fb952](https://github.com/henry-hsieh/personal-setup/commit/47fb952435193dbad9357329eb37adf4b69c1dae))
* **tinty:** bump tinty version to v0.20.1 ([#162](https://github.com/henry-hsieh/personal-setup/issues/162)) ([6eaa51e](https://github.com/henry-hsieh/personal-setup/commit/6eaa51e50cf600f3e77f5145bbccf975919dcfe9))
* **tinty:** bump tinty version to v0.21.0 ([#165](https://github.com/henry-hsieh/personal-setup/issues/165)) ([0a8601e](https://github.com/henry-hsieh/personal-setup/commit/0a8601ea2b823a7ab871eae52f3253eedd9cad69))
* **tinty:** bump tinty version to v0.21.1 ([#167](https://github.com/henry-hsieh/personal-setup/issues/167)) ([34ad151](https://github.com/henry-hsieh/personal-setup/commit/34ad151759d11a72491cf02182a3b63838e12ccc))
* **tinty:** bump tinty version to v0.22.0 ([#171](https://github.com/henry-hsieh/personal-setup/issues/171)) ([efa1b29](https://github.com/henry-hsieh/personal-setup/commit/efa1b29f6b44b5d609bc5f4b15284266ab61a41c))
* **tinty:** download tinty completion directly from Github ([#158](https://github.com/henry-hsieh/personal-setup/issues/158)) ([50663cb](https://github.com/henry-hsieh/personal-setup/commit/50663cbd0fde26339bfda28a280a03222356811e))
* **tmux:** bump tmux version to v3.5 ([#163](https://github.com/henry-hsieh/personal-setup/issues/163)) ([23b6c71](https://github.com/henry-hsieh/personal-setup/commit/23b6c7182e2e0964673d8ccaead1fbcad5420a22))
* **tree-sitter:** bump tree-sitter version to v0.23.1 ([#164](https://github.com/henry-hsieh/personal-setup/issues/164)) ([81eae15](https://github.com/henry-hsieh/personal-setup/commit/81eae158f68c204a0ace744b9feb40c8da48ecb4))
* **tree-sitter:** bump tree-sitter version to v0.23.2 ([#166](https://github.com/henry-hsieh/personal-setup/issues/166)) ([18b37a3](https://github.com/henry-hsieh/personal-setup/commit/18b37a338db5673fac0260592d2c8bbf3452fa6b))
* **tree-sitter:** bump tree-sitter version to v0.24.1 ([#169](https://github.com/henry-hsieh/personal-setup/issues/169)) ([c47df37](https://github.com/henry-hsieh/personal-setup/commit/c47df373cbd58eaf97a8540834b7567edfd5660d))
* **tree-sitter:** bump tree-sitter version to v0.24.2 ([#170](https://github.com/henry-hsieh/personal-setup/issues/170)) ([76c718a](https://github.com/henry-hsieh/personal-setup/commit/76c718af3e56c1974a3609d60b35cf2c86c340ce))
* **tree-sitter:** bump tree-sitter version to v0.24.3 ([#172](https://github.com/henry-hsieh/personal-setup/issues/172)) ([cfdce1b](https://github.com/henry-hsieh/personal-setup/commit/cfdce1b225aee3c5ea2c0ed121aae90874ebc388))

## [1.6.2](https://github.com/henry-hsieh/personal-setup/compare/v1.6.1...v1.6.2) (2024-09-14)


### Features

* **nvim:** add dressing.nvim as dependency of noice.nvim ([#149](https://github.com/henry-hsieh/personal-setup/issues/149)) ([99ed1ba](https://github.com/henry-hsieh/personal-setup/commit/99ed1ba62c335f4f26b4cd82598d1d6482c240cb))


### Miscellaneous Chores

* change version to 1.6.2 ([44316d9](https://github.com/henry-hsieh/personal-setup/commit/44316d933b9fc4039653bd7ae773002f4e62a11b))

## [1.6.1](https://github.com/henry-hsieh/personal-setup/compare/v1.6.0...v1.6.1) (2024-09-09)


### Features

* **rg:** bump rg version to v14.1.1 ([#145](https://github.com/henry-hsieh/personal-setup/issues/145)) ([cb9f4c6](https://github.com/henry-hsieh/personal-setup/commit/cb9f4c67aba43d96ecf33cffffe5a0af36c85ce1))
* **ts_ls:** rename tsserver to ts_ls ([#146](https://github.com/henry-hsieh/personal-setup/issues/146)) ([82ebeda](https://github.com/henry-hsieh/personal-setup/commit/82ebeda8b11b10838f4076b5ba56ff076f8b7ec4))


### Bug Fixes

* **gitsigns:** keymap desc should be wrapped in an option table ([#148](https://github.com/henry-hsieh/personal-setup/issues/148)) ([208f55b](https://github.com/henry-hsieh/personal-setup/commit/208f55ba395d0f720c0fa00a53deb57f4d5417a2))


### Miscellaneous Chores

* change version to 1.6.1 ([3785a7e](https://github.com/henry-hsieh/personal-setup/commit/3785a7e6da68fd03bcd97f62a596ed3c4eb1e42e))

## [1.6.0](https://github.com/henry-hsieh/personal-setup/compare/v1.5.1...v1.6.0) (2024-09-07)


### Features

* **fd:** bump fd version to v10.2.0 ([#139](https://github.com/henry-hsieh/personal-setup/issues/139)) ([9692021](https://github.com/henry-hsieh/personal-setup/commit/9692021dbc1c88b6488cea602afe830c65ba4adb))
* **fzf:** bump fzf version to v0.54.1 ([#124](https://github.com/henry-hsieh/personal-setup/issues/124)) ([8762ab5](https://github.com/henry-hsieh/personal-setup/commit/8762ab5146c98e43c1806a1e809062fdebb0d2ac))
* **fzf:** bump fzf version to v0.54.2 ([#131](https://github.com/henry-hsieh/personal-setup/issues/131)) ([2361fb6](https://github.com/henry-hsieh/personal-setup/commit/2361fb61d38dd15568c6adebe1f401095193eef8))
* **fzf:** bump fzf version to v0.54.3 ([#132](https://github.com/henry-hsieh/personal-setup/issues/132)) ([3f14983](https://github.com/henry-hsieh/personal-setup/commit/3f14983520a4042ddb05215b09d81caf38af914f))
* **fzf:** bump fzf version to v0.55.0 ([#142](https://github.com/henry-hsieh/personal-setup/issues/142)) ([4484414](https://github.com/henry-hsieh/personal-setup/commit/4484414173093c31f73ff8956e57b2e34cfe69fa))
* **install:** optimize installation progress ([#122](https://github.com/henry-hsieh/personal-setup/issues/122)) ([8a945fc](https://github.com/henry-hsieh/personal-setup/commit/8a945fca38be8ae53bc2a3fde6740273cd816a0a))
* **lazygit:** bump lazygit version to v0.44.0 ([#144](https://github.com/henry-hsieh/personal-setup/issues/144)) ([8454695](https://github.com/henry-hsieh/personal-setup/commit/8454695c78aea99a02676ae310cf040ad524f06d))
* **node:** bump node version to v22.7.0 ([#141](https://github.com/henry-hsieh/personal-setup/issues/141)) ([1859d12](https://github.com/henry-hsieh/personal-setup/commit/1859d12a1c0ef11015c011b17fabe06a44a2b061))
* **node:** bump node version to v22.8.0 ([#143](https://github.com/henry-hsieh/personal-setup/issues/143)) ([0f1750b](https://github.com/henry-hsieh/personal-setup/commit/0f1750b7fc0f3f1da3c89d39bfe198fcc1cc866a))
* **nvim:** add bufferline.nvim ([#128](https://github.com/henry-hsieh/personal-setup/issues/128)) ([b870fe9](https://github.com/henry-hsieh/personal-setup/commit/b870fe97955741e1aab76f86c4940e56cfbd88b8))
* **nvim:** add noice.nvim ([#138](https://github.com/henry-hsieh/personal-setup/issues/138)) ([75e3be2](https://github.com/henry-hsieh/personal-setup/commit/75e3be2ce4bed0d65058065f60eb220cfd694133))
* **nvim:** add which-key.nvim ([#123](https://github.com/henry-hsieh/personal-setup/issues/123)) ([d5df390](https://github.com/henry-hsieh/personal-setup/commit/d5df39011657c1e5d3205b9a96b91e0ba450b8f6))
* **nvim:** bump nvim version to v0.10.1 ([#129](https://github.com/henry-hsieh/personal-setup/issues/129)) ([56a611b](https://github.com/henry-hsieh/personal-setup/commit/56a611b8b5fa60006a4507212913b0217b1712fa))
* **nvim:** migrate project settings to neoconf.nvim ([#130](https://github.com/henry-hsieh/personal-setup/issues/130)) ([ead3531](https://github.com/henry-hsieh/personal-setup/commit/ead3531ff6320991f96bdbf70226a1d9444e85e2))
* **nvim:** update keymaps ([#136](https://github.com/henry-hsieh/personal-setup/issues/136)) ([9e6940c](https://github.com/henry-hsieh/personal-setup/commit/9e6940c6010ec10b004aa3b22dc651128583d409))
* **tmux:** change statusline position to top ([#137](https://github.com/henry-hsieh/personal-setup/issues/137)) ([034632b](https://github.com/henry-hsieh/personal-setup/commit/034632b6ec478995074bed66df3d97f3ede927c9))
* **tree-sitter:** bump tree-sitter version to v0.23.0 ([#140](https://github.com/henry-hsieh/personal-setup/issues/140)) ([cc1e64d](https://github.com/henry-hsieh/personal-setup/commit/cc1e64d59376a0465f64539f2a6b3e06a78a60bf))
* **yq:** bump yq version to v4.44.3 ([#133](https://github.com/henry-hsieh/personal-setup/issues/133)) ([7d374a8](https://github.com/henry-hsieh/personal-setup/commit/7d374a83cc1e3001baf23404bb1bff94e1d93fd2))


### Bug Fixes

* **nvim:** detour display flaws ([#127](https://github.com/henry-hsieh/personal-setup/issues/127)) ([2469fcc](https://github.com/henry-hsieh/personal-setup/commit/2469fcc0a858f515bfc1bde65e57b0c5346211d4))
* **tinty:** add completion to tinty wrap function ([#125](https://github.com/henry-hsieh/personal-setup/issues/125)) ([8cbd3e3](https://github.com/henry-hsieh/personal-setup/commit/8cbd3e3f36357b34239e99d3b7321a0c79e5e564))
* **tmux:** default shell should be a path to the shell ([#120](https://github.com/henry-hsieh/personal-setup/issues/120)) ([a4bfd03](https://github.com/henry-hsieh/personal-setup/commit/a4bfd03a05b5443f75438e193e2ce9794df01a8b))

## [1.5.1](https://github.com/henry-hsieh/personal-setup/compare/v1.5.0...v1.5.1) (2024-07-13)


### Features

* **lazygit:** bump lazygit version to v0.43.1 ([#117](https://github.com/henry-hsieh/personal-setup/issues/117)) ([3c10bc1](https://github.com/henry-hsieh/personal-setup/commit/3c10bc114e51a7a074f59489488b40b7b2641ba6))


### Miscellaneous Chores

* apply bug fix of lazygit ([#119](https://github.com/henry-hsieh/personal-setup/issues/119)) ([7684867](https://github.com/henry-hsieh/personal-setup/commit/7684867766123c2b608df4a909f3dd943c40d7ed))

## [1.5.0](https://github.com/henry-hsieh/personal-setup/compare/v1.4.0...v1.5.0) (2024-07-13)


### Features

* **fzf-tab-comp:** bump fzf-tab-comp digest to 1112259 ([#114](https://github.com/henry-hsieh/personal-setup/issues/114)) ([ee085a8](https://github.com/henry-hsieh/personal-setup/commit/ee085a868c0817d4018e21ea70fd62129388c302))
* **fzf-tab-comp:** bump fzf-tab-comp digest to ae8462e ([#110](https://github.com/henry-hsieh/personal-setup/issues/110)) ([b3a73a0](https://github.com/henry-hsieh/personal-setup/commit/b3a73a0f0556047e613fd10cc4179ef663676cda))
* **fzf:** bump fzf version to v0.54.0 ([#113](https://github.com/henry-hsieh/personal-setup/issues/113)) ([703b408](https://github.com/henry-hsieh/personal-setup/commit/703b408036524779c9274d8045b854c0ed60f02f))
* **git:** move config to XDG_CONFIG_HOME ([#98](https://github.com/henry-hsieh/personal-setup/issues/98)) ([a336bb6](https://github.com/henry-hsieh/personal-setup/commit/a336bb601452c5be3ff2a1f6cd07e02dce8e3140))
* **lazygit:** bump lazygit version to v0.43.0 ([#115](https://github.com/henry-hsieh/personal-setup/issues/115)) ([4fdd0e0](https://github.com/henry-hsieh/personal-setup/commit/4fdd0e0e3f103807dde75eb2f714b9997a2ff55d))
* **tinty:** bump tinty version to v0.15.0 ([#101](https://github.com/henry-hsieh/personal-setup/issues/101)) ([ed2eeeb](https://github.com/henry-hsieh/personal-setup/commit/ed2eeebeddd8716c7ad5a32edaf0e8f3fda8a24c))
* **tinty:** bump tinty version to v0.18.0 ([#111](https://github.com/henry-hsieh/personal-setup/issues/111)) ([a6ec7bd](https://github.com/henry-hsieh/personal-setup/commit/a6ec7bde126d1991b9c776b1449fd87c79d7b04d))
* **tmux:** bring back tmux-yank for clipboard selection ([#109](https://github.com/henry-hsieh/personal-setup/issues/109)) ([476b58a](https://github.com/henry-hsieh/personal-setup/commit/476b58ac90dc20c0ac791479140eae8fef955f0c))
* **tmux:** improve environment variables update ([#106](https://github.com/henry-hsieh/personal-setup/issues/106)) ([69e6d73](https://github.com/henry-hsieh/personal-setup/commit/69e6d73fc957f3f962baf204018204d371149573))
* **tmux:** move config to XDG_CONFIG_HOME ([#102](https://github.com/henry-hsieh/personal-setup/issues/102)) ([d5bcea7](https://github.com/henry-hsieh/personal-setup/commit/d5bcea74c93b9c312b90cc9a172f3bf6ee0af081))
* **yq:** add yq ([#116](https://github.com/henry-hsieh/personal-setup/issues/116)) ([e203c57](https://github.com/henry-hsieh/personal-setup/commit/e203c57fe016e4cb29ecc07e764a4039f8a45a84))


### Bug Fixes

* **bash:** fzf-tab-comb disable option ([#108](https://github.com/henry-hsieh/personal-setup/issues/108)) ([32fd945](https://github.com/henry-hsieh/personal-setup/commit/32fd9458d3795b01541356de83ae37c5876d3008))
* **bd:** tcsh error when executing bd without argument ([#107](https://github.com/henry-hsieh/personal-setup/issues/107)) ([988c90d](https://github.com/henry-hsieh/personal-setup/commit/988c90d0f4b439f5dcfb83267d579cca5aeb1ff5))
* **htop:** wrong manual download path ([#105](https://github.com/henry-hsieh/personal-setup/issues/105)) ([d9dc975](https://github.com/henry-hsieh/personal-setup/commit/d9dc975baa886a7a6d10184c6db3c2d270a68b57))
* **tmux:** path of tmux.conf reload is not correct ([#103](https://github.com/henry-hsieh/personal-setup/issues/103)) ([5334011](https://github.com/henry-hsieh/personal-setup/commit/53340118319b437c8726119946453c610ecbafad))

## [1.4.0](https://github.com/henry-hsieh/personal-setup/compare/v1.3.0...v1.4.0) (2024-06-08)


### Features

* **bash:** add option to disable fzf-tab-comp ([#91](https://github.com/henry-hsieh/personal-setup/issues/91)) ([28980f5](https://github.com/henry-hsieh/personal-setup/commit/28980f511776863ce9172b03b03d6bb5d929e673))
* **fd:** bump fd version to v10 ([#78](https://github.com/henry-hsieh/personal-setup/issues/78)) ([584d12a](https://github.com/henry-hsieh/personal-setup/commit/584d12ad47eceddd7baf4a0a40db1e3234d89fed))
* **fzf-tab-comp:** bump fzf-tab-comp digest to 2262b9f ([#86](https://github.com/henry-hsieh/personal-setup/issues/86)) ([caf17c4](https://github.com/henry-hsieh/personal-setup/commit/caf17c44373bd3820ee8798dd32ca6ea315f941c))
* **fzf-tab-comp:** bump fzf-tab-comp digest to 255dc81 ([#94](https://github.com/henry-hsieh/personal-setup/issues/94)) ([7fb0abc](https://github.com/henry-hsieh/personal-setup/commit/7fb0abcf53b09536e75fbf91619761053ea53bb8))
* **fzf:** bump fzf version to v0.52.1 ([#73](https://github.com/henry-hsieh/personal-setup/issues/73)) ([a630ce1](https://github.com/henry-hsieh/personal-setup/commit/a630ce1e200d86e2928091144c9275b3be1384cc))
* **fzf:** bump fzf version to v0.53.0 ([#95](https://github.com/henry-hsieh/personal-setup/issues/95)) ([f946919](https://github.com/henry-hsieh/personal-setup/commit/f946919274991b723ce82600f49b960ceecf7e6a))
* **fzf:** remove fzf-tmux in favor of builtin option ([#97](https://github.com/henry-hsieh/personal-setup/issues/97)) ([f28052d](https://github.com/henry-hsieh/personal-setup/commit/f28052d24ec764a708f114fd47b39c40ad9e5eea))
* **goto:** bump goto digest to b7fda54 ([#62](https://github.com/henry-hsieh/personal-setup/issues/62)) ([dac6361](https://github.com/henry-hsieh/personal-setup/commit/dac6361c9ac1f6a94aac15ac93daef1e4ed0e8b3))
* **htop:** add man of htop ([#93](https://github.com/henry-hsieh/personal-setup/issues/93)) ([22b784d](https://github.com/henry-hsieh/personal-setup/commit/22b784d8e6eb59ac52beea8a777477841b8a9313))
* **lazygit:** bump lazygit version to v0.42.0 ([#74](https://github.com/henry-hsieh/personal-setup/issues/74)) ([c8b2291](https://github.com/henry-hsieh/personal-setup/commit/c8b2291a51df05729b2b16ef05734f536f8e51f4))
* **node:** bump node version to v22 ([#79](https://github.com/henry-hsieh/personal-setup/issues/79)) ([abce844](https://github.com/henry-hsieh/personal-setup/commit/abce844502149a0ce2526786ed761d55e2c3718b))
* **nvim:** change directory to current file when open lazygit ([#96](https://github.com/henry-hsieh/personal-setup/issues/96)) ([c43d4d2](https://github.com/henry-hsieh/personal-setup/commit/c43d4d23064dd7b802f7c405b3921afa79f5ba89))
* **nvim:** enable autoread ([#90](https://github.com/henry-hsieh/personal-setup/issues/90)) ([5724e7a](https://github.com/henry-hsieh/personal-setup/commit/5724e7a2ae9d8a4f965a60b2e41b619ca97716e5))
* **rg:** bump rg version to v14.1.0 ([#76](https://github.com/henry-hsieh/personal-setup/issues/76)) ([77b7110](https://github.com/henry-hsieh/personal-setup/commit/77b711016b303a06419b3758db2528b1297627e3))
* **tinty:** bump tinty version to v0.14.0 ([#77](https://github.com/henry-hsieh/personal-setup/issues/77)) ([f0ed461](https://github.com/henry-hsieh/personal-setup/commit/f0ed46103badc6bbda8cb01cc4bf95c76e8f68d7))
* **tmux:** add man of tmux ([#92](https://github.com/henry-hsieh/personal-setup/issues/92)) ([41b7408](https://github.com/henry-hsieh/personal-setup/commit/41b7408dceb3d5cd7594b8844fbfdee8128c6e71))
* **tree-sitter:** bump tree-sitter version to v0.22.6 ([#72](https://github.com/henry-hsieh/personal-setup/issues/72)) ([60d1414](https://github.com/henry-hsieh/personal-setup/commit/60d14140df9d0a24ba0703385c2aa62d96dc6459))


### Bug Fixes

* **goto:** revert to release version ([#84](https://github.com/henry-hsieh/personal-setup/issues/84)) ([70745db](https://github.com/henry-hsieh/personal-setup/commit/70745dba16b12c6aec915acbf50f488fcfc99daf))

## [1.3.0](https://github.com/henry-hsieh/personal-setup/compare/v1.2.0...v1.3.0) (2024-05-12)


### Features

* **git:** always prune removed remote branches ([#38](https://github.com/henry-hsieh/personal-setup/issues/38)) ([63356ae](https://github.com/henry-hsieh/personal-setup/commit/63356ae436235e11a401a90964ec4f2d13fbaf73))
* **lazygit:** add lazygit config ([#31](https://github.com/henry-hsieh/personal-setup/issues/31)) ([92ef232](https://github.com/henry-hsieh/personal-setup/commit/92ef2327dfadfd3409a806d8e2096468cf08df4d))
* **nvim:** change keymap of terminal exit ([#29](https://github.com/henry-hsieh/personal-setup/issues/29)) ([064b35d](https://github.com/henry-hsieh/personal-setup/commit/064b35d6991ee05aa192287c263e61638289dba8))
* **rustup:** add rustup ([#39](https://github.com/henry-hsieh/personal-setup/issues/39)) ([8e59c10](https://github.com/henry-hsieh/personal-setup/commit/8e59c10f52c83a29c14d1e983870b02f7f141386))
* **tmux:** remove tmux-yank and use built-in copy ([#34](https://github.com/henry-hsieh/personal-setup/issues/34)) ([43b3c6c](https://github.com/henry-hsieh/personal-setup/commit/43b3c6cd498a4bb150ebb6a852010f3276fdd90b))


### Bug Fixes

* **nvim:** change colorscheme after create autocmd ([#28](https://github.com/henry-hsieh/personal-setup/issues/28)) ([2ebf260](https://github.com/henry-hsieh/personal-setup/commit/2ebf2606b587bed8655c029eb13fa3a9517b63f7))
* **tinty:** move tinty config to correct path ([#32](https://github.com/henry-hsieh/personal-setup/issues/32)) ([2c201bd](https://github.com/henry-hsieh/personal-setup/commit/2c201bd79dcf4a3a191b296662a1104967981616))
* **tmux:** set TMUX_PLUGIN_MANAGER_PATH in .tmux.conf ([#36](https://github.com/henry-hsieh/personal-setup/issues/36)) ([40e9e8e](https://github.com/henry-hsieh/personal-setup/commit/40e9e8e96da8aa6d240a5aa23f854048a70159c0))

## [1.2.0](https://github.com/henry-hsieh/personal-setup/compare/v1.1.0...v1.2.0) (2024-05-05)


### Features

* **htop:** add htop ([#24](https://github.com/henry-hsieh/personal-setup/issues/24)) ([5ecc882](https://github.com/henry-hsieh/personal-setup/commit/5ecc88249bbc995127d33fd70c0e5f500b2582fc))
* **lazygit:** add lazygit ([#22](https://github.com/henry-hsieh/personal-setup/issues/22)) ([5e23fdb](https://github.com/henry-hsieh/personal-setup/commit/5e23fdbe65629c55e7f732177b1d56b7a8186c8d))
* **nvim:** add detour.nvim ([#25](https://github.com/henry-hsieh/personal-setup/issues/25)) ([1a1733f](https://github.com/henry-hsieh/personal-setup/commit/1a1733f691102ed5bf15c7d158a362bdd1980c91))
* **nvim:** optimize neovim settings ([#27](https://github.com/henry-hsieh/personal-setup/issues/27)) ([7454d0e](https://github.com/henry-hsieh/personal-setup/commit/7454d0e17dc5d1ee3cfaf322501f00adf8130a0c))
* **tinty:** add bash completion ([#21](https://github.com/henry-hsieh/personal-setup/issues/21)) ([50c11fa](https://github.com/henry-hsieh/personal-setup/commit/50c11fad317e56a9d1336cb2d947d6c48c5535be))
* **tinty:** update tinty version to v0.12.0 ([#23](https://github.com/henry-hsieh/personal-setup/issues/23)) ([6edaa46](https://github.com/henry-hsieh/personal-setup/commit/6edaa46216c91e092780556c66ba44dc7ba3c988))
* **tinty:** use tinty to manage themes ([#14](https://github.com/henry-hsieh/personal-setup/issues/14)) ([836a9cc](https://github.com/henry-hsieh/personal-setup/commit/836a9cc476051d1e85c00df2585eda786a231cd3))


### Bug Fixes

* **nvim:** hop end accidently modify hop option ([#17](https://github.com/henry-hsieh/personal-setup/issues/17)) ([d7b5f12](https://github.com/henry-hsieh/personal-setup/commit/d7b5f1218ea0dc6c87b4e8499b086e70b61e8d0d))
* **tinty:** not start in shell init ([#26](https://github.com/henry-hsieh/personal-setup/issues/26)) ([2ad694c](https://github.com/henry-hsieh/personal-setup/commit/2ad694cd0cfddca886291e2d1498ebb20f17fedb))
* **tinty:** synchronize scheme updates of tmux and nvim ([#20](https://github.com/henry-hsieh/personal-setup/issues/20)) ([5ccdadc](https://github.com/henry-hsieh/personal-setup/commit/5ccdadcc27cf1189f16cfcaa0b59d26bb3ce8f1e))

## [1.1.0](https://github.com/henry-hsieh/personal-setup/compare/v1.0.0...v1.1.0) (2024-04-25)


### Features

* **git-extras:** add git-extras to extend git commands ([#13](https://github.com/henry-hsieh/personal-setup/issues/13)) ([7143878](https://github.com/henry-hsieh/personal-setup/commit/71438783b8bb6310aebd5c783182b66f1ded53e3))
* **nvim:** change riscv-asm-vim to lazy load ([#7](https://github.com/henry-hsieh/personal-setup/issues/7)) ([0e94159](https://github.com/henry-hsieh/personal-setup/commit/0e94159c0c818a8aba023da6bc3174d43ab97610))
* **tmux:** upgrade tmux to v3.4 ([#11](https://github.com/henry-hsieh/personal-setup/issues/11)) ([199a14b](https://github.com/henry-hsieh/personal-setup/commit/199a14beb787c838de211ef13813a7286169f254))


### Bug Fixes

* **jdk:** make JDK version precise to get correct URL ([#12](https://github.com/henry-hsieh/personal-setup/issues/12)) ([b35bbe7](https://github.com/henry-hsieh/personal-setup/commit/b35bbe78ac36b586d27aa52d87d8d8bbfaa4cc7e))
* **nvim:** feline not change color after switch colorscheme ([#15](https://github.com/henry-hsieh/personal-setup/issues/15)) ([f959ed7](https://github.com/henry-hsieh/personal-setup/commit/f959ed7f695fa14cbd7fd73e1fc5e6fc9a167ac6))
* **nvim:** reverse telescope move direction ([#16](https://github.com/henry-hsieh/personal-setup/issues/16)) ([09ba831](https://github.com/henry-hsieh/personal-setup/commit/09ba8310b45ef33eeccbf10506107b32fb0a7357))

## 1.0.0 (2024-04-08)


### Features

* initial commit ([c7af21a](https://github.com/henry-hsieh/personal-setup/commit/c7af21a59fc5cb74cc6e7addcb5b016b509364c4))
