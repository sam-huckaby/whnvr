import * as esbuild from 'esbuild';

let ctx = await esbuild.context({
  entryPoints: [
	  'scripts/authenticate_passkey.js',
	  'scripts/bind_new_passkey.js',
	  'scripts/extend_account.js',
	  'scripts/feed_handlers.js',
	  'scripts/list_passkeys_to_delete.js',
	  'scripts/load_passkeys.js',
	  'scripts/namespace_bi.js',
  ],
  outdir: 'www/static',
  outExtension: { '.js': '.dist.js' },
  bundle: true,
  minify: true,
});

await ctx.watch();
console.log('watching...');
