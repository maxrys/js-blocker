<html lang="en">
<head>
    <?php $domain = $_SERVER['HTTP_HOST']; $isInFrame = isset($_GET['isFrame']); ?>
    <meta charset="utf-8">
    <title>JS Blocker Test: <?php print($domain) ?></title>
    <link href="style.css" rel="stylesheet" media="all">

    <!-- INLINE HEAD SCRIPT -->
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            document.getElementById('inline_head_script').setAttribute('data-js-active', '');
        });
    </script>

    <!-- EXTERNAL SCRIPTS -->
    <script           src="https://js-blocker.com/script.js.php" defer></script>
    <script src="https://subdomain.js-blocker.com/script.js.php" defer></script>
    <script           src="https://js-blocker/script.js.php"     defer></script>

</head>
<body onload="document.getElementById('inline_attr_script').setAttribute('data-js-active', '');"
      <?php print($isInFrame ? "data-is-frame" : "data-is-top") ?>>

    <!-- TITLE -->
    <h1><?php print($domain) ?></h1>

    <!-- INDICATORS -->
    <x-states>
        <?php if (!$isInFrame) { ?>
            <x-title>JS States</x-title>
        <?php } ?>
        <x-indicator x-type="external_script"           x-domain="js-blocker.com">External JS from           js-blocker.com</x-indicator>
        <x-indicator x-type="external_script" x-domain="subdomain.js-blocker.com">External JS from subdomain.js-blocker.com</x-indicator>
        <x-indicator x-type="external_script"           x-domain="js-blocker"    >External JS from           js-blocker    </x-indicator>
        <x-indicator id="inline_attr_script">Inline JS Attribute Script</x-indicator>
        <x-indicator id="inline_head_script">Inline JS Head Script</x-indicator>
        <x-indicator id="inline_body_script">Inline JS Body Script</x-indicator>
    </x-states>

    <!-- INLINE BODY SCRIPT -->
    <script>
        document.getElementById('inline_body_script').setAttribute('data-js-active', '');
    </script>

    <!-- iFRAMES -->
    <x-frames>
        <?php if (!$isInFrame) { ?>
            <x-title>Frames</x-title>
            <iframe height="190" width="280"           src="https://js-blocker.com?isFrame"></iframe>
            <iframe height="190" width="280" src="https://subdomain.js-blocker.com?isFrame"></iframe>
            <iframe height="190" width="280"               src="https://js-blocker?isFrame"></iframe>
        <?php } ?>
    </x-frames>

    <!-- MENU -->
    <?php if (!$isInFrame) { ?>
        <x-links>
            <x-block>
                <x-title>Main links</x-title>
                <a target="js_blocker_com"                     href="https://js-blocker.com">           js-blocker.com </a>
                <a target="subdomain_js_blocker_com" href="https://subdomain.js-blocker.com"> subdomain.js-blocker.com </a>
                <a target="js_blocker"                         href="https://js-blocker"    >           js-blocker     </a>
            </x-block>
        </x-links>
    <?php } ?>

</body>
</html>