/*
 *  Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package org.ballerinalang.plugins.idea.structureview;

import com.intellij.icons.AllIcons;
import com.intellij.lang.ASTNode;
import com.intellij.navigation.ItemPresentation;
import com.intellij.psi.PsiElement;
import org.ballerinalang.plugins.idea.BallerinaIcons;
import org.ballerinalang.plugins.idea.psi.ActionDefinitionNode;
import org.ballerinalang.plugins.idea.psi.AnnotationDefinitionNode;
import org.ballerinalang.plugins.idea.psi.ConnectorNode;
import org.ballerinalang.plugins.idea.psi.FunctionNode;
import org.ballerinalang.plugins.idea.psi.ResourceDefinitionNode;
import org.ballerinalang.plugins.idea.psi.ServiceDefinitionNode;
import org.ballerinalang.plugins.idea.psi.StructDefinitionNode;
import org.jetbrains.annotations.Nullable;

import javax.swing.Icon;

public class BallerinaItemPresentation implements ItemPresentation {

    protected final PsiElement element;

    protected BallerinaItemPresentation(PsiElement element) {
        this.element = element;
    }

    @Nullable
    @Override
    public Icon getIcon(boolean unused) {
        if (element.getParent() instanceof FunctionNode) {
            return AllIcons.Nodes.Field;
        } else if (element.getParent() instanceof ConnectorNode || element instanceof ConnectorNode) {
            return AllIcons.Nodes.Class;
        } else if (element.getParent() instanceof ServiceDefinitionNode || element instanceof ServiceDefinitionNode) {
            return AllIcons.Nodes.Static;
        } else if (element.getParent() instanceof AnnotationDefinitionNode) {
            return AllIcons.Nodes.Annotationtype;
        } else if (element.getParent() instanceof ActionDefinitionNode) {
            return AllIcons.Nodes.Advice;
        } else if (element.getParent() instanceof StructDefinitionNode) {
            return AllIcons.Json.Object;
        } else if (element.getParent() instanceof ResourceDefinitionNode) {
            return AllIcons.Nodes.Advice;
        }
        return BallerinaIcons.ICON;
    }

    @Nullable
    @Override
    public String getPresentableText() {
        // Todo - Add parameters, return types
        ASTNode node = element.getNode();
        if (element instanceof ConnectorNode) {
            PsiElement nameIdentifier = ((ConnectorNode) element).getNameIdentifier();
            if (nameIdentifier != null) {
                return nameIdentifier.getText();
            }
        } else if (element instanceof ServiceDefinitionNode) {
            PsiElement nameIdentifier = ((ServiceDefinitionNode) element).getNameIdentifier();
            if (nameIdentifier != null) {
                return nameIdentifier.getText();
            }
        }
        return node.getText();
    }

    @Nullable
    @Override
    public String getLocationString() {
        return null;
    }
}
