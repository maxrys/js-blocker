<?php
    $domain = idn_to_utf8($_SERVER['HTTP_HOST'], IDNA_DEFAULT, INTL_IDNA_VARIANT_UTS46);
    $isInFrame = isset($_GET['isFrame']);
?><html lang="en">
<head>
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
    <script         src="https://js-blocker.com/script.js.php" defer></script>
    <script     src="https://sub.js-blocker.com/script.js.php" defer></script>
    <script src="https://sub.sub.js-blocker.com/script.js.php" defer></script>
    <script         src="https://js-блоккер/script.js.php?anyRandomValue=<?php print(random_int(0, 1000)); ?>" defer></script>

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
        <x-indicator id="inline_attr_script">Inline JS Attribute Script</x-indicator>
        <x-indicator id="inline_head_script">Inline JS Head Script</x-indicator>
        <x-indicator id="inline_body_script">Inline JS Body Script</x-indicator>
        <x-indicator x-type="external_script"         x-domain="js-blocker.com">External JS from         js-blocker.com</x-indicator>
        <x-indicator x-type="external_script"     x-domain="sub.js-blocker.com">External JS from     sub.js-blocker.com</x-indicator>
        <x-indicator x-type="external_script" x-domain="sub.sub.js-blocker.com">External JS from sub.sub.js-blocker.com</x-indicator>
        <x-indicator x-type="external_script"    x-domain="xn--js--dddu3aag1ax">External JS from         js-блоккер    </x-indicator>
    </x-states>

    <!-- INLINE BODY SCRIPT -->
    <script>
        document.getElementById('inline_body_script').setAttribute('data-js-active', '');
    </script>

    <!-- iFRAMES -->
    <x-frames>
        <?php if (!$isInFrame) { ?>
            <x-title>Frames</x-title>
            <iframe width="280" height="205"         src="https://js-blocker.com?isFrame"></iframe>
            <iframe width="280" height="205"     src="https://sub.js-blocker.com?isFrame"></iframe>
            <iframe width="280" height="205" src="https://sub.sub.js-blocker.com?isFrame"></iframe>
            <iframe width="280" height="205"         src="https://js-блоккер?isFrame"    ></iframe>
        <?php } ?>
    </x-frames>

    <!-- MENU -->
    <?php if (!$isInFrame) { ?>
        <x-links>
            <x-block>
                <x-title>Main links</x-title>
                <a         target="js_blocker_com"         href="https://js-blocker.com">         js-blocker.com </a>
                <a     target="sub_js_blocker_com"     href="https://sub.js-blocker.com">     sub.js-blocker.com </a>
                <a target="sub_sub_js_blocker_com" href="https://sub.sub.js-blocker.com"> sub.sub.js-blocker.com </a>
                <a        target="js_блоккер"              href="https://js-блоккер"    >         js-блоккер     </a>
            </x-block>
        </x-links>
    <?php } ?>
    
    <!-- TEST ELEMENTS WITH JS -->
    <?php if (!$isInFrame) { ?>
        <x-links>
            <x-block>
                <a href="javascript:alert('JS is enabled')">Link with JS: click to test</a>
                <a href="JavaScript:alert('JS is enabled')">Link with JS: click to test</a>
                <a href="     javascript:alert('JS is enabled')">Link with JS: click to test</a>
                <a href="&#x6a;avascript:alert('JS is enabled')">Link with JS: click to test</a>
                <x-title>Frame with srcdoc</x-title>
                <iframe
                    width="280" height="50"
                    sandbox="allow-scripts allow-same-origin"
                    srcdoc='<?php include("special/frame-srcdoc.html"); ?>'>
                </iframe>
            </x-block>
        </x-links>
    <?php } ?>

    <!-- DYNAMIC IFRAME -->
    <?php if (!$isInFrame) { ?>
        <x-dynamic>
            <x-title>Dynamic Frames</x-title>
            <?php include("special/dynamic-frames.html"); ?>
        </x-dynamic>
    <?php } ?>

</body>
</html>