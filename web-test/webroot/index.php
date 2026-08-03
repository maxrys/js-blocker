<html lang="en">
<head>
    <?php $domain = $_SERVER['HTTP_HOST']; $isInFrame = isset($_GET['isFrame']); ?>
    <meta charset="utf-8">
    <title>JS Blocker Test page</title>
    <link href="style.css" rel="stylesheet" media="all">

    <!-- INLINE HEAD SCRIPT -->
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            document.getElementById('inline_head_script').setAttribute('data-js-active', '');
        });
    </script>

    <!-- EXTERNAL SCRIPTS -->
    <script                src="https://js-blocker.com/script.js.php" defer></script>
    <script           src="https://sub1.js-blocker.com/script.js.php" defer></script>
    <script      src="https://sub2.sub1.js-blocker.com/script.js.php" defer></script>
    <script src="https://sub3.sub2.sub1.js-blocker.com/script.js.php" defer></script>
    <script                src="https://js-blocker/script.js.php"     defer></script>

</head>
<body onload="document.getElementById('inline_attr_script').setAttribute('data-js-active', '');"
      <?php if ($isInFrame) print("data-is-frame") ?>>

    <!-- TITLE -->
    <h1><?php print($domain) ?></h1>

    <!-- MENU -->
    <?php if (!$isInFrame) { ?>
        <x-links>
            <x-block>
                <x-title>Main links</x-title>
                <a                target="js_blocker_com"                href="https://js-blocker.com">js-blocker.com</a>
                <a           target="sub1_js_blocker_com"           href="https://sub1.js-blocker.com">sub1.js-blocker.com</a>
                <a      target="sub2_sub1_js-blocker_com"      href="https://sub2.sub1.js-blocker.com">sub2.sub1.js-blocker.com</a>
                <a target="sub3_sub2_sub1_js_blocker_com" href="https://sub3.sub2.sub1.js-blocker.com">sub3.sub2.sub1.js-blocker.com</a>
            </x-block>
            <x-block>
                <x-title>Additional links</x-title>
                <a target="www_js_blocker_com" href="https://www.js-blocker.com">www.js-blocker.com</a>
                <a target="js_blocker"         href="https://js-blocker">js-blocker</a>
            </x-block>
        </x-links>
    <?php } ?>

    <!-- INDICATORS -->
    <x-states>
        <?php if (!$isInFrame) { ?>
            <x-title>JS States</x-title>
        <?php } ?>
        <x-indicator x-type="external_script"                x-domain="js-blocker.com">External JS from                js-blocker.com</x-indicator>
        <x-indicator x-type="external_script"           x-domain="sub1.js-blocker.com">External JS from           sub1.js-blocker.com</x-indicator>
        <x-indicator x-type="external_script"      x-domain="sub2.sub1.js-blocker.com">External JS from      sub2.sub1.js-blocker.com</x-indicator>
        <x-indicator x-type="external_script" x-domain="sub3.sub2.sub1.js-blocker.com">External JS from sub3.sub2.sub1.js-blocker.com</x-indicator>
        <x-indicator x-type="external_script"                x-domain="js-blocker"    >External JS from                js-blocker    </x-indicator>
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
            <?php if ($domain !==                'js-blocker.com') { ?> <iframe height="225" width="280"                src="https://js-blocker.com?isFrame"></iframe> <?php } ?>
            <?php if ($domain !==           'sub1.js-blocker.com') { ?> <iframe height="225" width="280"           src="https://sub1.js-blocker.com?isFrame"></iframe> <?php } ?>
            <?php if ($domain !==      'sub2.sub1.js-blocker.com') { ?> <iframe height="225" width="280"      src="https://sub2.sub1.js-blocker.com?isFrame"></iframe> <?php } ?>
            <?php if ($domain !== 'sub3.sub2.sub1.js-blocker.com') { ?> <iframe height="225" width="280" src="https://sub3.sub2.sub1.js-blocker.com?isFrame"></iframe> <?php } ?>
            <?php if ($domain !==                'js-blocker'    ) { ?> <iframe height="225" width="280"                    src="https://js-blocker?isFrame"></iframe> <?php } ?>
        <?php } ?>
    </x-frames>

</body>
</html>