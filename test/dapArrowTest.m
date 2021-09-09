classdef dapArrowTest < matlab.unittest.TestCase
    properties
        Property1
    end
    
    methods (Test)
        function test_set_parent(testCase)
            fh = figure();
            cleanup = onCleanup(@()delete(fh));
            fh.Visible = "off";
            
            CHILDREN_TO_ADD = 2;
            arrow = dapArrow();
            
            axh = axes(fh);
            expected = numel(axh.Children) + CHILDREN_TO_ADD;
            arrow.set_parent(axh);
            actual = numel(axh.Children);
            testCase.verifyEqual(actual, expected);
            
            uiaxh = uiaxes(fh);
            uiexpected = numel(uiaxh.Children) + CHILDREN_TO_ADD;
            arrow.set_parent(uiaxh);
            uiactual = numel(uiaxh.Children);
            testCase.verifyEqual(uiactual, uiexpected);
        end
        
        function test_graphics(testCase)
            % visually compare figures
            COUNT = 3;
            scale = [200 500];
            da = cell(numel(scale), COUNT);
            fhs = cell(numel(scale), 2);
            for s = 1 : numel(scale)
                sz = scale(s);
                x = 50 + sum(scale(1:s-1));
                fh = figure();
                fh.Position = [x 50 sz sz + 250];
                fhs{s, 1} = fh;
                fhs{s, 2} = onCleanup(@()delete(fh));
                axh = axes(fh);
                hold(axh, "on");

                Y_TAIL = 0;
                Y_HEAD = 1;

                axh.XLim = [0 COUNT + 1];
                axh.YLim = [Y_TAIL Y_HEAD] + [-1 1];
                axh.ZLim = [0 5];

                for i = 1 : COUNT
                    da{s, i} = dapArrow();
                    da{s, i}.head = [i + (i - 1) * 0.1 Y_HEAD];
                    da{s, i}.tail = [i Y_TAIL];
                    da{s, i}.set_parent(axh);
                    da{s, i}.visible = true;
                end

                testCase.assertTrue(3 <= numel(da));
                da{s, 1}.line_width = 0.5;
                da{s, 1}.head_size_pt = [6 6];
                da{s, 1}.color = Color.RED();

                da{s, 2}.line_width = 1;
                da{s, 2}.head_size_pt = [12 12];
                da{s, 2}.color = Color.GREEN();

                da{s, 3}.line_width = 2;
                da{s, 3}.head_size_pt = [24 24];
                da{s, 3}.color = Color.BLUE();

                for i = 1 : COUNT
                    da{s, i}.update();
                end
            end
                
            pause(5);
        end
    end
end

