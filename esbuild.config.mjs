import * as esbuild from 'esbuild';

let ctx = await esbuild.context({
  entryPoints: [
	  'scripts/bind_new_passkey.js',
	  'scripts/load_passkeys.js',
	  'scripts/list_passkeys_to_delete.js',
	  'scripts/authenticate_passkey.js',
  ],
  outdir: 'www/static',
  outExtension: { '.js': '.dist.js' },
  bundle: true,
  minify: true,
});

await ctx.watch();
console.log('watching...');
