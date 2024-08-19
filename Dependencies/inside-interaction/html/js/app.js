
$(document).ready(function() {
    var $progressCircle = $('.progress-bar');
    var $buttonContainer = $('#interaction-button-container');

    var animation = null;
    var fullDuration = 1500; 
    var startOffset = Math.PI * 2 * 45;
    var currentOffset = startOffset;

    var buttonInteractionId;
    var displayInteractionId;
    var typeInteraction;
    var indexInteraction;

    function startProgress() {
        var circumference = Math.PI * 2 * 45;

        $progressCircle.css({
            'stroke-dasharray': circumference,
            'stroke-dashoffset': currentOffset
        });

        var remainingDuration = (currentOffset / circumference) * fullDuration; 

        $buttonContainer.css({
            'transform': 'translate(-50%, -50%) scale(0.85)'
        });
        

        animation = $({ offset: currentOffset }).animate({ offset: 0 }, {
            duration: remainingDuration,
            step: function(now) {
                currentOffset = now;
                $progressCircle.css('stroke-dashoffset', now);
            },
            easing: 'linear',
            complete: function() {
                resetProgress();
                $.post('https://inside-interaction/progressSuccess', JSON.stringify({ entity: buttonInteractionId, id: displayInteractionId, type: typeInteraction, index: indexInteraction }))
            }
        });
    }

    function stopProgress() {
        if (animation) {
            animation.stop();
        }

        $buttonContainer.css({
            'transform': 'translate(-50%, -50%) scale(1.0)'
        });
    }

    function resetProgress() {
        if (animation) {
            animation.stop();
            animation = null;

            currentOffset = startOffset;
            $progressCircle.css('stroke-dashoffset', startOffset);

            $buttonContainer.css({
                'transform': 'translate(-50%, -50%) scale(1.0)'
            });
            return
        }
    }

    window.startProgress = startProgress;
    window.stopProgress = stopProgress;
    window.resetProgress = resetProgress;

    function updateInteractionTargets(entities) {
        for (let i = 1; i <= 10; i++) {
            let targetId = `interaction-target-${i}`;
            let $target = $(`#${targetId}`);
    
            if (i <= entities.length) {
                let entity = entities[i - 1];
                let translateY = 50 - (entity.scale * 50);
    
                $target.css({
                    'display': 'flex',
                    'left': (entity.x * window.innerWidth) + 'px',
                    'bottom': (window.innerHeight - (entity.y * window.innerHeight)) + 'px',
                    'transform': 'translateX(-50%) translateY(' + translateY + '%) scale(' + entity.scale + ')'
                });
            } else {
                $target.hide();
            }
        }
    }

    window.addEventListener('message', function(event) {
        let data = event.data;

        if (data.action === "updateTarget") {
            if (data.display && data.entities) {
                updateInteractionTargets(data.entities);
            } else {
                $('#interaction-targets-container').children().hide(); 
            }

        } else if (data.action === "updateClosestTarget") {
            let $option = $('#interaction-option');
            let $optionText = $("#option-text");
            let $optionButton = $("#option-button");
            let $optionIcon = $("#interaction-option-icon");
            let $scroll = $('#interaction-scroll');
            let $rotateUp = $('.rotate-up');
            let $rotateDown = $('.rotate-down');

            if (data.display) {
                if (data.entity.id !== buttonInteractionId) {
                    buttonInteractionId = data.entity.id;
                    resetProgress();
                }

                if (data.entity.option.duration !== fullDuration) {
                    fullDuration = data.entity.option.duration
                }

                if (data.entity.Display !== displayInteractionId || data.entity.Type !== typeInteraction || data.entity.Index !== indexInteraction) {
                    displayInteractionId = data.entity.Display
                    typeInteraction = data.entity.Type
                    indexInteraction = data.entity.Index || null;
                }

                if ($optionIcon.attr("class") !== data.entity.option.icon) {
                    $optionIcon.attr("class", data.entity.option.icon);
                }

                if ($optionText.text() !== data.entity.option.label) {
                    $optionText.text(data.entity.option.label);                
                }

                if ($optionButton.text() !== data.entity.option.key) {
                    $optionButton.text(data.entity.option.key);
                }

                if (data.entity.scroll) {
                    $scroll.css('display', 'flex');
            
                    if (data.entity.up && !$rotateUp.hasClass("scroll-active")) {
                        $rotateUp.addClass("scroll-active");     
                        resetProgress();
                    } else if (!data.entity.up && $rotateUp.hasClass("scroll-active")) {
                        $rotateUp.removeClass("scroll-active");
                        resetProgress();
                    }

                    if (data.entity.down && !$rotateDown.hasClass("scroll-active")) {
                        $rotateDown.addClass("scroll-active");
                        resetProgress();
                    } else if (!data.entity.down && $rotateDown.hasClass("scroll-active")) {
                        $rotateDown.removeClass("scroll-active");
                        resetProgress();
                    }
                } else {
                    $scroll.css('display', 'none');
                }

                $option.css({
                    'display': 'flex',
                    'left': (data.entity.x * window.innerWidth) + 'px',
                    'bottom': (window.innerHeight - (data.entity.y * window.innerHeight)) + 50 + 'px',
                    'transform': 'translateX(-50%) translateY(0)'
                });
            } else {
                resetProgress()
                $option.css('display', 'none');
            }
        } else if (data.action === "buttonClick") {
            startProgress();
        } else if (data.action === "buttonReset") {
            resetProgress();
        }
    });
});